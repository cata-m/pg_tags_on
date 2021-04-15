# frozen_string_literal: true

module PgTagsOn
  module Repositories
    # This repository works with "character varying[]" and "integer[]" column types
    class ArrayRepository < BaseRepository
      def all
        subquery = klass
                   .select(arel_distinct(array_to_recordset).as('name'))
                   .arel
                   .as('tags')

        PgTagsOn::Tag
          .select(Arel.star)
          .from(subquery)
          .order('tags.name') # override rails' default order by id
      end

      def all_with_counts
        taggings
          .except(:select)
          .select('name, count(name) as count')
          .group('name')
      end

      def find(tag)
        all.where(name: tag).first
      end

      def exists?(tag)
        all.exists?(tag)
      end

      def taggings
        PgTagsOn::Tag
          .select(Arel.star)
          .from(taggings_query)
          .order('taggings.name')
      end

      def count
        all.count
      end

      def create(tag_or_tags, returning: nil)
        value = arel_array_cat(arel_column, bind_for(Array.wrap(tag_or_tags)))

        perform_update(klass, { column_name => value }, returning: returning)
      end

      def update(tag, new_tag, returning: nil)
        rel = klass.where(column_name => PgTagsOn.query_class.one(tag))
        value = arel_array_replace(arel_column, bind_for(tag), bind_for(new_tag))

        perform_update(rel, { column_name => value }, returning: returning)
      end

      def delete(tag_or_tags, returning: nil)
        tags = Array.wrap(tag_or_tags)
        rel = klass.where(column_name => PgTagsOn.query_class.any(tags))
        sm = Arel::SelectManager.new
                                .project(unnest)
                                .except(
                                  Arel::SelectManager.new
                                    .project(arel_unnest(arel_cast(bind_for(tags), native_column_type)))
                                )
        value = arel_function('array', sm)

        perform_update(rel, { column_name => value }, returning: returning)
      end

      private

      def perform_update(rel, updates, returning: nil)
        update_manager = get_update_manager(rel, updates)
        sql, binds = klass.connection.send :to_sql_and_binds, update_manager
        sql += " RETURNING #{Array.wrap(returning).join(', ')}" if returning.present?

        result = klass.connection.exec_query(sql, 'SQL', binds).rows

        returning ? result : true
      end

      def taggings_query
        klass
          .select(
            array_to_recordset.as('name'),
            arel_table['id'].as('entity_id')
          )
          .arel
          .as('taggings')
      end

      def unnest
        arel_unnest(arel_column)
      end

      def array_to_recordset
        unnest
      end

      def unnest_with_ordinality(alias_table: 't')
        "#{unnest.to_sql} WITH ORDINALITY #{alias_table}(name, index)"
      end

      def query_attribute(value)
        arel_query_attribute(arel_column, value, cast_type)
      end

      def bind_for(value, attr = arel_column)
        query_attr = arel_query_attribute(attr, value, cast_type)
        arel_bind(query_attr)
      end
    end
  end
end
