# frozen_string_literal: true

module PgTagsOn
  module ActiveRecord
    # Arel extension
    module Arel
      def arel_function(name, *args)
        ::Arel::Nodes::NamedFunction.new(name, args)
      end

      # unnest function
      # +attr+ Arel attribute
      def arel_unnest(attr)
        arel_function('unnest', attr)
      end

      # distinct function
      def arel_distinct(node)
        arel_function('distinct', node)
      end

      # array_cat function
      def arel_array_cat(attr, value)
        arel_function('array_cat', attr, value)
      end

      # array_replace function
      def arel_array_replace(attr, value1, value2)
        arel_function('array_replace', attr, value1, value2)
      end

      # array_remove function
      def arel_array_remove(attr, value)
        arel_function('array_remove', attr, value)
      end

      def arel_jsonb_extract_path(attr, *args)
        arel_function('jsonb_extract_path', [attr, *args])
      end

      def arel_query_attribute(attr, value, cast_type)
        ::ActiveRecord::Relation::QueryAttribute.new(attr, value, cast_type)
      end

      def arel_bind(query_attr)
        ::Arel::Nodes::BindParam.new(query_attr)
      end

      def arel_infix_operation(operator, left, right)
        ::Arel::Nodes::InfixOperation.new(operator, left, right)
      end

      def arel_cast(attr, type)
        ::Arel::Nodes::InfixOperation.new('::', attr, arel_sql(type))
      end

      def arel_sql(expr)
        ::Arel.sql(expr)
      end

      def arel_build_quoted(expr)
        ::Arel::Nodes.build_quoted(expr)
      end
    end
  end
end
