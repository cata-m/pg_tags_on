# frozen_string_literal: true

WITH_COVERAGE = ENV['COVERAGE']

if WITH_COVERAGE
  require 'simplecov'
  SimpleCov.start do
    add_filter %r{/benchmark/}
  end
end

require 'pg'
require 'active_record'
require 'bundler/setup'
require 'pg_tags_on'
require 'helpers/database_helpers'
require 'support/factory'
require 'pry'

RSpec.configure do |config|
  # Enable flags like --only-failures and --next-failure
  config.example_status_persistence_file_path = '.rspec_status'

  # Disable RSpec exposing methods globally on `Module` and `main`
  config.disable_monkey_patching!

  config.expect_with :rspec do |c|
    c.syntax = :expect
  end

  config.include DatabaseHelpers

  config.before(:all) do
    DatabaseHelpers.establish_connection
    DatabaseHelpers.load_schema
  end
end

Entity = Class.new(::ActiveRecord::Base)
