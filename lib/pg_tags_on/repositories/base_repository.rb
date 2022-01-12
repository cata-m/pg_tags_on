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

      ##
      # ActiveRecord Column instance
      #
      def ar_column
        @ar_column ||= klass.columns_hash[column_name.to_s]
      end

      ##
      # Column's Type instance
      #
      # @return [ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Array]
      #
      def cast_type
        @cast_type ||= klass.type_for_attribute(column_name)
      end

      ##
      # Database column type as string.
      #
      # @return [String] "character varying[]", "integer[]"
      #
      def native_column_type
        type = ::ActiveRecord::ConnectionAdapters::PostgreSQLAdapter::NATIVE_DATABASE_TYPES.fetch(cast_type.type)[:name]
        type += '[]' if ar_column.array?

        type
      end

      # Method copied from ActiveRecord as there is no way to inject sql into update manager.
      def get_update_manager(relation:, updates:)
        raise ArgumentError, 'Empty list of attributes to change' if updates.blank?

        stmt = ::Arel::UpdateManager.new
        stmt.table(arel_table)
        stmt.key = arel_table[klass.primary_key]
        stmt.take(relation.arel.limit)
        stmt.offset(relation.arel.offset)
        stmt.order(*relation.arel.orders)
        stmt.wheres = relation.arel.constraints
        stmt.set relation.send(:_substitute_values, updates)

        stmt
      end

      def update_attributes(relation:, attributes:, returning: nil)
        manager = get_update_manager relation: relation, updates: attributes
        sql, binds = klass.connection.send :to_sql_and_binds, manager
        sql += " RETURNING #{returning}" if returning.present?

        result = klass.connection.exec_query(sql, 'SQL', binds).rows

        returning ? result : true
      end
    end
  end
end
