# frozen_string_literal: true

module PgTagsOn
  # Models' predicate handlers register this class
  class PredicateHandler < ::ActiveRecord::PredicateBuilder::BasicObjectHandler
    def call(attribute, query)
      handler = Builder.new(attribute, query, predicate_builder).call

      handler.call
    end

    # Handler builder class
    class Builder
      def initialize(attribute, query, predicate_builder)
        @attribute = attribute
        @query = query
        @predicate_builder = predicate_builder
      end

      def call
        if column.array?
          array_handler
        else
          BasicObjectHandler.new attribute, query, predicate_builder
        end
      end

      private

      attr_reader :attribute, :query, :predicate_builder

      def klass
        @klass ||= predicate_builder.send(:table).send(:klass)
      end

      def column
        @column ||= klass.columns_hash[attribute.name]
      end

      def column_type
        @column_type ||= column.type.to_s
      end

      def settings
        @settings ||= (klass.pg_tags_on_options_for(attribute.name) || {}).symbolize_keys
      end

      def array_handler
        handler_klass =
          if column_type == 'jsonb'
            if settings.key?(:has_attributes)
              ArrayJsonbWithAttrsHandler
            else
              ArrayJsonbHandler
            end
          else
            PredicateHandler.const_get("Array#{column_type.classify}Handler")
          end

        handler_klass.new(attribute, query, predicate_builder)
      end
    end
  end
end
