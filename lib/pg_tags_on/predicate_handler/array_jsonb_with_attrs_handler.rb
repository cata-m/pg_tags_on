# frozen_string_literal: true

module PgTagsOn
  class PredicateHandler
    # Predicate handler for jsonb[] column type
    class ArrayJsonbWithAttrsHandler < ArrayJsonbHandler
      OPERATORS = {
        eq: :eq,
        all: '?&',
        any: '?|',
        in: '<@',
        one: '?&'
      }.freeze

      def left
        node = arel_function('array_to_json', attribute)
        node = arel_cast(node, 'jsonb')
        node = arel_function('jsonb_path_query_array', node, arel_build_quoted("$[*].#{key.join('.')}"))

        node
      end

      def right
        if predicate == :in
          arel_cast(arel_sql("'#{value.to_json}'"), 'jsonb')
        else
          super
        end
      end

      def value
        @value ||= Array.wrap(query.value)
      end

      def cast_type
        subtype = ActiveModel::Type::String.new
        ::ActiveRecord::ConnectionAdapters::PostgreSQL::OID::Array.new(subtype)
      end
    end
  end
end
