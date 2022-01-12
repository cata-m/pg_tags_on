# frozen_string_literal: true

module PgTagsOn
  ##
  # Repository class for tags.
  #
  # Examples:
  #
  #   repo = PgTagsOn::Repository.new(Entity, :tags)
  #   repo.all
  #   repo.update('foo', 'boo')
  #   ...
  #
  class Repository
    extend Forwardable
    def_delegators :gateway, :all, :all_with_counts, :taggings, :count, :create, :update, :delete

    attr_reader :klass, :column_name

    def initialize(klass, column_name)
      @klass = klass
      @column_name = column_name.to_s
    end

    private

    def gateway
      raise 'Invalid column type' unless column.array?

      @gateway ||= send("#{column.type}_gateway")
    end

    def column
      @column ||= klass.columns_hash[column_name]
    end

    def default_gateway
      PgTagsOn::Repositories::ArrayRepository.new(klass, column_name, settings)
    end

    def string_gateway
      default_gateway
    end

    def text_gateway
      default_gateway
    end

    def integer_gateway
      default_gateway
    end

    def jsonb_gateway
      PgTagsOn::Repositories::ArrayJsonbRepository.new(klass, column_name, settings)
    end

    def settings
      @settings ||= (klass.pg_tags_on_options_for(column_name) || {}).symbolize_keys
    end
  end
end
