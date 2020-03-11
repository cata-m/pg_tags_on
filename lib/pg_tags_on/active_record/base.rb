# frozen_string_literal: true

module PgTagsOn
  module ActiveRecord
    # ActiveRecord::Base extension
    module Base
      extend ActiveSupport::Concern

      class_methods do
        def pg_tags_on(name, options = {})
          raise PgTagsOn::ColumnNotFoundError, "#{name} column not found" unless column_names.include?(name.to_s)

          pg_tags_on_init_model unless @pg_tags_on_init_model
          pg_tags_on_settings[name] = options.deep_symbolize_keys
          validates(name, 'pg_tags_on/tags': true) if %i[limit tag_length].any? { |k| options[k] }
          instance_eval <<-RUBY, __FILE__, __LINE__ + 1
            scope :#{name}, -> { PgTagsOn::Repository.new(self, "#{name}") }
          RUBY
        end

        def pg_tags_on_init_model
          @pg_tags_on_init_model ||= begin
            PgTagsOn.register_query_class
            predicate_builder.register_handler(PgTagsOn.query_class, PgTagsOn::PredicateHandler.new(predicate_builder))
            cattr_accessor :pg_tags_on_settings
            self.pg_tags_on_settings ||= {}.with_indifferent_access
          end
        end

        def pg_tags_on_options_for(name)
          self.pg_tags_on_settings[name.to_sym]
        end

        def pg_tags_on_reset
          @pg_tags_on_init_model = false
          self.pg_tags_on_settings = nil
        end
      end
    end
  end
end
