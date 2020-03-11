# frozen_string_literal: true

$LOAD_PATH.unshift File.dirname(__FILE__)

require 'active_record'
require 'active_support/all'
require 'faker'
require './lib/pg_tags_on'

Dir['tasks/**/*.rake'].each { |rake| load rake }

require 'bundler/gem_tasks'
Bundler::GemHelper.install_tasks

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:spec)
