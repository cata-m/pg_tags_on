# frozen_string_literal: true

module PgTagsOn
  # Model for tags.
  # Schema is defined dynamically and has only +name+ column as string.
  class Tag < ::ActiveRecord::Base
    self.table_name = 'tags'

    class << self
      def load_schema!
        @load_schema ||= begin
          name_column = ::ActiveRecord::ConnectionAdapters::PostgreSQL::Column.new('name', '', pg_string_type)
          @columns_hash = { 'name' => name_column }
        end
      end

      private

      def pg_string_type
        string = ::ActiveRecord::ConnectionAdapters::SqlTypeMetadata.new(sql_type: 'character varying', type: 'string')
        ::ActiveRecord::ConnectionAdapters::PostgreSQL::TypeMetadata.new(string)
      end
    end

    def inspect
      info = attributes.map { |name, value| %(#{name}: #{format_for_inspect(value)}) }.join(', ')

      "#<#{self.class.name} #{info}>"
    end
  end
end
