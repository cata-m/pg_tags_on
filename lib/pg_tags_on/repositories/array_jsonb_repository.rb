# frozen_string_literal: true

module PgTagsOn
  module Repositories
    # Operatons for 'jsonb[]' column type
    class ArrayJsonbRepository < ArrayRepository
      def create(tag_or_tags, returning: nil)
        tags = normalize_tags(Array.wrap(tag_or_tags))

        super(tags, returning: returning)
      end

      def update(tag, new_tag, returning: nil)
        n_tag, n_new_tag = normalize_tags([tag, new_tag])

        sql_set = <<-SQL.strip
          #{column_name}[index] = #{column_name}[index] || $2
        SQL

        update_tag(n_tag,
                   sql_set,
                   bindings: [query_attribute(n_new_tag.to_json)],
                   returning: returning)
      end

      def delete(tag_or_tags, returning: nil)
        tags = Array.wrap(tag_or_tags)
        normalized_tags = normalize_tags(tags)
        rel = klass.where(column_name => PgTagsOn.query_class.any(tags))
        sm = build_tags_select_manager
        normalized_tags.each do |tag|
          sm.where(arel_infix_operation('@>', Arel.sql('tag'), bind_for(tag.to_json, nil)).not)
        end
        value = arel_function('array', sm)

        perform_update(rel, { column_name => value }, returning: returning)
      end

      private

      # Returns SelectManager for unnested tags.
      # sql: select tag from ( select unnest(tags_jsonb) as tag ) as _tags
      def build_tags_select_manager
        Arel::SelectManager.new
                           .project('tag')
                           .from(Arel::SelectManager.new
                  .project(unnest.as('tag'))
                  .as('_tags'))
      end

      def normalize_tags(tags)
        return tags unless key?

        tags.map do |tag|
          Array.wrap(key).reverse.inject(tag) { |a, n| { n => a } }
        end
      end

      def array_to_recordset
        return unnest unless key?

        arel_jsonb_extract_path(unnest, *key_sql)
      end

      def key
        @key ||= options[:key]
      end

      def key_sql
        @key_sql ||= Array.wrap(key).map { |k| Arel.sql("'#{k}'") }
      end

      def key?
        key.present?
      end

      def taggings_with_ordinality_query(tag)
        column = Arel::Table.new('t')['name']
        value = bind_for(tag.to_json, nil)

        arel_table
          .project('id, name, index')
          .from("#{table_name}, #{unnest_with_ordinality}")
          .where(arel_infix_operation('@>', column, value))
      end

      def update_tag(tag, set_sql, bindings: [], returning: nil)
        subquery = taggings_with_ordinality_query(tag)
                   .where(arel_table[:id].in(arel_sql(klass.reselect('id').to_sql)))

        sql = <<-SQL.strip
          WITH records as ( #{subquery.to_sql} )
          UPDATE #{table_name}
          SET #{set_sql}
          FROM records
          WHERE #{table_name}.id = records.id
        SQL

        sql += " RETURNING #{Array.wrap(returning).join(', ')}" if returning.present?

        bindings = [query_attribute(tag.to_json)] + Array.wrap(bindings)
        result = klass.connection.exec_query(sql, 'SQL', bindings).rows

        returning ? result : true
      end
    end
  end
end
