# frozen_string_literal: true

module PgTagsOn
  class PredicateHandler
    # Predicate handler for jsonb[] column type
    class ArrayJsonbHandler < BaseHandler
      # Transforms value in Hash if :key option is set
      def value
        @value ||= begin
          return query_value unless key?

          query_value.each.map do |val|
            key.reverse.inject(val) { |a, n| { n => a } }
          end
        end
      end

      def query_value
        @query_value ||= Array.wrap(query.value)
      end

      def key
        @key ||= Array.wrap(settings[:key])
      end

      def key?
        key.present?
      end
    end
  end
end
