# frozen_string_literal: true

require 'forwardable'

require 'pg_tags_on/version'
require 'pg_tags_on/active_record/base'
require 'pg_tags_on/active_record/arel'
require 'pg_tags_on/predicate_handler'
require 'pg_tags_on/predicate_handler/base_handler'
require 'pg_tags_on/predicate_handler/array_string_handler'
require 'pg_tags_on/predicate_handler/array_text_handler'
require 'pg_tags_on/predicate_handler/array_integer_handler'
require 'pg_tags_on/predicate_handler/array_jsonb_handler'
require 'pg_tags_on/predicate_handler/array_jsonb_with_attrs_handler'
require 'pg_tags_on/tag'
require 'pg_tags_on/tags_query'
require 'pg_tags_on/validations/validator'
require 'pg_tags_on/repository'
require 'pg_tags_on/repositories/base_repository'
require 'pg_tags_on/repositories/array_repository'
require 'pg_tags_on/repositories/array_value/create'
require 'pg_tags_on/repositories/array_value/update'
require 'pg_tags_on/repositories/array_value/delete'
require 'pg_tags_on/repositories/array_jsonb_repository'
require 'pg_tags_on/repositories/array_jsonb/create'
require 'pg_tags_on/repositories/array_jsonb/update'
require 'pg_tags_on/repositories/array_jsonb/delete'
require 'pg_tags_on/benchmark/benchmark'

# PgTagsOn configuration methods
module PgTagsOn
  class Error < StandardError; end
  class ColumnNotFoundError < Error; end

  def configure
    @config ||= OpenStruct.new(query_class: 'Tags')
    yield @config if block_given?
    @config
  end

  def configuration
    @config || configure
  end

  def register_query_class
    return true if query_class?

    Kernel.const_set(PgTagsOn.configuration.query_class.to_sym, PgTagsOn::TagsQuery)
  end

  def query_class?
    Kernel.const_defined?(PgTagsOn.configuration.query_class)
  end

  def query_class
    Kernel.const_get(PgTagsOn.configuration.query_class)
  end

  module_function :configure, :configuration, :register_query_class, :query_class, :query_class?
end

ActiveRecord::Base.include PgTagsOn::ActiveRecord::Base
