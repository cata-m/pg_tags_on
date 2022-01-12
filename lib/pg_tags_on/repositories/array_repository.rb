# frozen_string_literal: true

module PgTagsOn
  module Repositories
    # This repository works with "character varying[]" and "integer[]" column types
    class ArrayRepository < BaseRepository
      ##
      # Select all tags ordered by name
      #
      # @return [Array[PgTagsOn::Tag]] Tags list.
      #
      # @example
      #   Entity.tags.all
      #
      def all
        PgTagsOn::Tag
          .select(Arel.star)
          .from(select_tags.as('tags'))
          .order(tag_alias)
      end

      ##
      # Select all tags with counts
      #
      # @return [Array[PgTagsOn::Tag]] Tags list.
      #
      # @example
      #   Entity.tags.all_with_counts
      #
      def all_with_counts
        taggings
          .reselect("#{tag_alias}, count(*) as count")
          .group(tag_alias)
      end

      ##
      # Find one tag.
      #
      # @return [PgTagsOn::Tag]
      #
      def find(tag)
        all.where(name: tag).first
      end

      ##
      # Returns true if tag exists.
      #
      # @return [Boolean]
      #
      def exists?(tag)
        all.exists? tag
      end

      ##
      # Select taggings.
      #
      # @return [[PgTagsOn::Tag<entity_id, name>]]
      #
      def taggings
        PgTagsOn::Tag
          .select(Arel.star)
          .from(select_taggings.as('taggings'))
          .order(tag_alias)
      end

      ##
      # Get tags count.
      #
      def count
        all.count
      end

      ##
      # Add tag(s) to records.
      #
      # @param tag_or_tags [String|Array] Tags to be added.
      # @param returning   [String]         Model's columns that'll be returned.
      #
      # @return [Array|Boolean] Returns boolean if :returning argument is nil
      #
      # @example
      #   Entity.tags.create "lorem", returning: "id,name"
      #     => [[1, 'row1'], [2, 'row2']]
      #
      def create(tag_or_tags, returning: nil)
        ArrayValue::Create.new.call repository: self,
                                    relation: klass,
                                    tags: tag_or_tags,
                                    returning: returning
      end

      ##
      # Rename tag(s).
      #
      # @param tag       [String] Tag that'll be renamed.
      # @param new_tag   [String] New tag name.
      # @param returning [String] Model's columns that'll be returned.
      #
      # @return [Array|Boolean] Returns boolean if :returning argument is nil
      #
      # @example
      #   Entity.tags.update "lorem", "ipsum", returning: "id,name"
      #     => [[1, 'row1'], [2, 'row2']]
      #
      def update(tag, new_tag, returning: nil)
        relation = klass.where(column_name => PgTagsOn.query_class.one(tag))

        ArrayValue::Update.new.call repository: self,
                                    relation: relation,
                                    tag: tag,
                                    new_tag: new_tag,
                                    returning: returning
      end

      ##
      # Delete tag(s).
      #
      # @param tag_or_tags [String] Tag that'll be renamed.
      # @param returning   [String] Model's columns that'll be returned.
      #
      # @return [Array|Boolean] Returns boolean if :returning argument is nil
      #
      # @example
      #   Entity.tags.delete "lorem", returning: "id,name"
      #     => [[1, 'row1'], [2, 'row2']]
      #
      def delete(tag_or_tags, returning: nil)
        relation = klass.where(column_name => PgTagsOn.query_class.any(tag_or_tags))

        ArrayValue::Delete.new.call repository: self,
                                    relation: relation,
                                    tags: tag_or_tags,
                                    returning: returning
      end

      def tag_alias
        'name'
      end

      # protected

      ##
      # @return [Arel::SelectManager]
      #
      def select_tags
        klass
          .select(arel_distinct(arel_unnest(arel_column)).as(tag_alias))
          .arel
      end

      ##
      # @return [Arel::SelectManager]
      #
      def select_taggings
        klass
          .select(arel_unnest(arel_column).as(tag_alias),
                  arel_table['id'].as('entity_id'))
          .arel
      end

      def bind_for(value, attr = arel_column)
        query_attr = arel_query_attribute attr, value, cast_type
        arel_bind query_attr
      end
    end
  end
end
