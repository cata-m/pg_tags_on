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

      def create(tag, returning: nil)
        raise 'Tag cannot be blank' if tag.blank?

        perform_update(klass,
                       { column_name => arel_array_cat(arel_column, bind_for(Array.wrap(tag))) },
                       returning: returning)
      end

      def update(tag, new_tag, returning: nil)
        raise 'Tag cannot be blank' if tag.blank? || new_tag.blank?

        rel = klass.where(column_name => PgTagsOn.query_class.one(tag))

        perform_update(rel,
                       { column_name => arel_array_replace(arel_column, bind_for(tag), bind_for(new_tag)) },
                       returning: returning)
      end

      def delete(tag, returning: nil)
        raise 'Tag cannot be blank' if tag.blank?

        rel = klass.where(column_name => PgTagsOn.query_class.one(tag))

        perform_update(rel, { column_name => arel_array_remove(arel_column, bind_for(tag)) }, returning: returning)
      end

      private

      def perform_update(rel, updates, returning: nil)
        updater = update_manager(rel, updates)
        sql, binds = klass.connection.send :to_sql_and_binds, updater
        sql += " RETURNING #{Array.wrap(returning).join(', ')}" if returning.present?

        result = klass.connection.exec_query(sql, 'SQL', binds).rows

        returning ? result : true
      end

      # Method copied from ActiveRecord as there is no way to inject sql into update manager.
      def update_manager(rel, updates)
        raise ArgumentError, 'Empty list of attributes to change' if updates.blank?

        stmt = ::Arel::UpdateManager.new
        stmt.table(arel_table)
        stmt.key = klass.arel_attribute(klass.primary_key)
        stmt.take(rel.arel.limit)
        stmt.offset(rel.arel.offset)
        stmt.order(*rel.arel.orders)
        stmt.wheres = rel.arel.constraints
        stmt.set rel.send(:_substitute_values, updates)

        stmt
      end

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
