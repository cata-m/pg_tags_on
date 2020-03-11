# frozen_string_literal: true

module PgTagsOn
  class PredicateHandler
    # Base predicate handler
    class BaseHandler
      include PgTagsOn::ActiveRecord::Arel

      OPERATORS = {
        eq: :eq,
        all: '@>',
        any: '&&',
        in: '<@',
        one: '@>'
      }.freeze

      def initialize(attribute, query, predicate_builder)
        @attribute = attribute
        @query = query
        @predicate_builder = predicate_builder
      end

      def call
        raise 'Invalid predicate' unless OPERATORS.keys.include?(predicate)

        if operator.is_a?(Symbol)
          send("#{operator}_node")
        else
          ::Arel::Nodes::InfixOperation.new(operator, left, right)
        end
      end

      def predicate
        @predicate ||= query.predicate.to_sym
      end

      def operator
        @operator ||= self.class.const_get('OPERATORS').fetch(predicate)
      end

      def eq_node
        node = ::Arel::Nodes::InfixOperation.new(self.class::OPERATORS[:all], left, right)
        node.and(arel_function('array_length', attribute, 1).eq(value.size))
      end

      def left
        attribute
      end

      def right
        bind_node
      end

      def bind_node
        query_attr = ::ActiveRecord::Relation::QueryAttribute.new(attribute_name, value, cast_type)
        Arel::Nodes::BindParam.new(query_attr)
      end

      def value
        @value ||= Array.wrap(query.value)
      end

      def klass
        @klass ||= predicate_builder.send(:table).send(:klass)
      end

      def table_name
        @table_name ||= attribute.relation.name
      end

      def attribute_name
        attribute.name.to_s
      end

      # Returns Type object
      def cast_type
        @cast_type ||= klass.type_for_attribute(attribute_name)
      end

      def settings
        @settings ||= (klass.pg_tags_on_options_for(attribute_name) || {}).symbolize_keys
      end

      private

      attr_reader :attribute, :query, :predicate_builder
    end
  end
end
