# frozen_string_literal: true

module PgTagsOn
  module Repositories
    # Operatons for 'jsonb[]' column type
    class ArrayJsonbRepository < ArrayRepository
      def create(tag, returning: nil)
        with_normalized_tags(tag) do |n_tag|
          super(n_tag, returning: returning)
        end
      end

      def update(tag, new_tag, returning: nil)
        with_normalized_tags(tag, new_tag) do |n_tag, n_new_tag|
          sql_set = <<-SQL.strip
            #{column_name}[index] = #{column_name}[index] || $2
          SQL

          update_tag(n_tag,
                     sql_set,
                     bindings: [query_attribute(n_new_tag.to_json)],
                     returning: returning)
        end
      end

      def delete(tag, returning: nil)
        with_normalized_tags(tag) do |n_tag|
          sql_set = <<-SQL.strip
            #{column_name} = #{column_name}[1:index-1] || #{column_name}[index+1:2147483647]
          SQL

          update_tag(n_tag, sql_set, returning: returning)
        end
      end

      private

      def with_normalized_tags(*tags, &block)
        normalized_tags = Array.wrap(tags).flatten.map do |tag|
          key? && Array.wrap(key).reverse.inject(tag) { |a, n| { n => a } } || tag
        end

        block.call(*normalized_tags)
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
