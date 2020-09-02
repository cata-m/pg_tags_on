# frozen_string_literal: true

module PgTagsOn
  module Repositories
    # Base class for repositories.
    class BaseRepository
      include ::PgTagsOn::ActiveRecord::Arel

      def self.api_methods
        %i[all all_with_counts find exists? taggings count create update delete to_s]
      end

      api_methods.each do |m|
        define_method(m) do
          raise 'Not implemented'
        end
      end

      attr_reader :klass, :column_name, :options

      def initialize(klass, column_name, options = {})
        @klass = klass
        @column_name = column_name
        @options = options.deep_symbolize_keys
      end

      def table_name
        @table_name ||= klass.table_name
      end

      def arel_table
        klass.arel_table
      end

      def arel_column
        arel_table[column_name]
      end

      # Returns ActiveRecord Column instance
      def ar_column
        @ar_column ||= klass.columns_hash[column_name.to_s]
      end

      def ref
        "#{table_name}.#{column_name}"
      end

      # Returns Type instance
      def cast_type
        @cast_type ||= klass.type_for_attribute(column_name)
      end

      # Returns db type as string.
      # Ex: character varying[], integer[]
      def native_column_type
        type = ::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::NATIVE_DATABASE_TYPES.fetch(cast_type.type)[:name]
        type += '[]' if ar_column.array?

        type
      end

      # Method copied from ActiveRecord as there is no way to inject sql into update manager.
      def get_update_manager(rel, updates)
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
    end
  end
end
