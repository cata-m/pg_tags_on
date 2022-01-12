# frozen_string_literal: true

require 'benchmark'
require './spec/helpers/database_helpers'
require 'lib/pg_tags_on'
require 'pry'

namespace :pg_tags_on do
  task :benchmark do
    DatabaseHelpers.establish_connection
    DatabaseHelpers.load_schema

    Entity = Class.new(::ActiveRecord::Base)
    Entity.pg_tags_on :tags_int
    Entity.pg_tags_on :tags_str
    Entity.pg_tags_on :tags_jsonb, key: :name

    puts 'How many records to generate? (default 10_000)'
    records = $stdin.gets.chomp.to_i
    puts 'Minimum tags per record (default 1):'
    min_tags = $stdin.gets.chomp.to_i
    puts 'Maximum tags per record (default 10):'
    max_tags = $stdin.gets.chomp.to_i

    records = 10_000 if records.zero?
    min_tags = 1 if min_tags.zero?
    max_tags = 10 if max_tags.zero?

    data = []
    str_tags = Array.new(100) { Faker::Name.first_name }

    puts "Generating #{records} records..."
    records.times do
      tags_count = rand(min_tags..max_tags)

      data << {
        tags_int: Array.new(tags_count) { rand(1..100) },
        tags_str: str_tags.sample(tags_count),
        tags_jsonb: Array.new(tags_count) { { name: str_tags.sample } }
      }

      if data.size == 5_000
        Entity.insert_all data
        data = []
      end
    end

    Entity.insert_all(data) if data.present?
    puts 'Done'

    puts "\n\n* character varying[]\n\n"
    PgTagsOn::Benchmark.new(Entity, :tags_str).call
    puts "\n\n* integer[]\n\n"
    PgTagsOn::Benchmark.new(Entity, :tags_int).call
    puts "\n\n* jsonb[]\n\n"
    PgTagsOn::Benchmark.new(Entity, :tags_jsonb).call
  end
end
