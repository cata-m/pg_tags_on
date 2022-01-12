# frozen_string_literal: true

module PgTagsOn
  module Repositories
    module ArrayValue
      # This class is respnsible to delete tags stored as JSON objects.
      class Update
        include ::PgTagsOn::ActiveRecord::Arel

        delegate :column_name, :arel_column, :bind_for, to: :repository

        def call(repository:, relation:, tag:, new_tag:, returning: nil)
          @repository = repository
          value = arel_array_replace arel_column, bind_for(tag), bind_for(new_tag)

          repository.update_attributes relation: relation,
                                       attributes: { column_name => value },
                                       returning: returning
        end

        private

        attr_reader :repository, :tags
      end
    end
  end
end
