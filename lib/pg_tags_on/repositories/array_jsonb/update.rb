# frozen_string_literal: true

module PgTagsOn
  module Repositories
    module ArrayJsonb
      # This class is respnsible to update tags stored as JSON objects.
      class Update
        include ::PgTagsOn::ActiveRecord::Arel

        delegate :table_name, :column_name, :tag_alias,
                 :arel_table, :arel_column, :cast_type, :bind_for, to: :repository

        def call(repository:, relation:, tag:, new_tag:, returning: nil)
          @repository = repository
          @relation = relation
          sql = <<-SQL
            WITH tag_positions AS ( #{select_tag_positions(tag).to_sql} )
            UPDATE #{table_name}
            SET #{column_name}[index] = #{column_name}[index] || $2
            FROM tag_positions
            WHERE #{table_name}.id = tag_positions.id
          SQL
          sql += " RETURNING #{returning}" if returning.present?
          bindings = [
            arel_query_attribute(arel_column, tag.to_json, cast_type),
            arel_query_attribute(arel_column, new_tag.to_json, cast_type)
          ]

          result = relation.connection.exec_query(sql, 'SQL', bindings).rows

          returning ? result : true
        end

        private

        attr_reader :repository, :relation

        ##
        # For each record explode tags and their position index
        # and select only occurences of the given tag value
        #
        # @param tag [String|Hash] Normalized tag value.
        #
        def select_tag_positions(tag)
          condition1 = arel_infix_operation '@>',
                                            Arel::Table.new('t')[tag_alias],
                                            bind_for(tag.to_json, nil)
          condition2 = arel_table[:id].in arel_sql(relation.reselect('id').to_sql)

          arel_table
            .project("id, #{tag_alias}, index")
            .from("#{table_name}, #{arel_unnest(arel_column).to_sql} WITH ORDINALITY t(#{tag_alias}, index)")
            .where(condition1)
            .where(condition2)
        end
      end
    end
  end
end
