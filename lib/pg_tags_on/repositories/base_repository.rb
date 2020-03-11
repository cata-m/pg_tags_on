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

      def cast_type
        @cast_type ||= klass.type_for_attribute(column_name)
      end

      def arel_table
        klass.arel_table
      end

      def arel_column
        arel_table[column_name]
      end
    end
  end
end
