# frozen_string_literal: true

module PgTagsOn
  # Helper class to construct queries.
  # This class is registered in models' predicate builders.
  # See configuration in order to create an alias for it.
  class TagsQuery
    %w[one all any in eq].each do |predicate|
      instance_eval <<-RUBY, __FILE__, __LINE__ + 1
        def #{predicate}(*args)
          params = args.size == 1 ? args.first : args
          new(params, "#{predicate}")
        end
      RUBY
    end

    attr_reader :value
    attr_reader :predicate
    attr_reader :options

    def initialize(value, predicate, options = {})
      @value = value
      @predicate = predicate
      @options = options
    end
  end
end
