# frozen_string_literal: true

module PgTagsOn
  module Repositories
    module ArrayJsonb
      # This class is respnsible to delete tags stored as JSON objects.
      class Delete
        include ::PgTagsOn::ActiveRecord::Arel

        delegate :column_name, :tag_alias,
                 :arel_column, :bind_for, to: :repository

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
          query = Arel::SelectManager.new
                                     .project(tag_alias)
                                     .from(Arel::SelectManager.new
                                            .project(arel_unnest(arel_column).as(tag_alias))
                                            .as('update_tags'))
          Array.wrap(tags).each do |tag|
            query.where arel_infix_operation('@>', Arel.sql(tag_alias), bind_for(tag.to_json, nil)).not
          end

          query
        end
      end
    end
  end
end
