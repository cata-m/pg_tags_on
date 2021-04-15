# frozen_string_literal: true

module PgTagsOn
  # Validator for max. number of tags and max. tag length.
  #
  #   class Entity
  #     pg_tags_on :tags, limit: 20, length: 64
  #   end
  #
  class TagsValidator < ActiveModel::EachValidator
    def initialize(options = {})
      super
      @klass = options[:class]
    end

    def validate_each(record, attribute, value)
      validate_limit(record, attribute, value)
      validate_length(record, attribute, value)

      record.errors.present?
    end

    private

    attr_reader :klass

    def validate_limit(record, attr, value)
      limit = klass.pg_tags_on_options_for(attr)[:limit]
      return true unless limit && value

      record.errors.add(attr, "size exceeded #{limit} tags") if value.size > limit.to_i
    end

    def validate_length(record, attr, value)
      limit, key = klass.pg_tags_on_options_for(attr).values_at(:length, :key)
      return true unless limit && value

      value.map! { |tag| tag.with_indifferent_access.dig(*key) } if key

      record.errors.add(attr, "length exceeded #{limit} characters") if value.any? { |val| val.size > limit.to_i }
    end
  end
end
