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

      def create(tag)
        return true if tag.blank?

        klass.update_all(column_name => arel_array_cat(arel_column, bind_for(Array.wrap(tag))))
      end

      def update(tag, new_tag)
        return true if tag.blank? || new_tag.blank? || tag == new_tag

        klass
          .where(column_name => Tags.one(tag))
          .update_all(column_name => arel_array_replace(arel_column, bind_for(tag), bind_for(new_tag)))
      end

      def delete(tag)
        klass
          .where(column_name => Tags.one(tag))
          .update_all(column_name => arel_array_remove(arel_column, bind_for(tag)))
      end

      private

      def array_to_recordset
        unnest
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

      def ref
        "#{table_name}.#{column_name}"
      end

      def unnest
        arel_unnest(arel_column)
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
