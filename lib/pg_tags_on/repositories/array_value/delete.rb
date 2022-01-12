# frozen_string_literal: true

module PgTagsOn
  module Repositories
    module ArrayValue
      # This class is respnsible to delete tags stored as JSON objects.
      class Delete
        include ::PgTagsOn::ActiveRecord::Arel

        delegate :column_name, :arel_column, :bind_for, :native_column_type, to: :repository

        def call(repository:, relation:, tags:, returning: nil)
          @repository = repository
          @tags = tags

          repository.update_attributes relation: relation,
                                       attributes: { column_name => arel_function('array', active_tags) },
                                       returning: returning
        end

        private

        attr_reader :repository, :tags

        ##
        # For each record explode tags and filter out tags to be removed
        #
        def active_tags
          Arel::SelectManager.new
                             .project(arel_unnest(arel_column))
                             .except(Arel::SelectManager.new
                              .project(arel_unnest(arel_cast(bind_for(Array.wrap(tags)), native_column_type))))
        end
      end
    end
  end
end
