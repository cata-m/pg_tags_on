# frozen_string_literal: true

module PgTagsOn
  module Repositories
    # Operatons for 'jsonb[]' column type
    class ArrayJsonbRepository < ArrayRepository
      ##
      # Tag's key in the JSON object.
      # Can be a String or Array for nested attributes.
      #
      # @example
      #   { "name" => "lorem" } ;              key = 'tag'
      #   { "tag" => { "name" => "lorem" } } ; key = ['tag', 'name']
      #
      def key
        @key ||= options[:key]
      end

      ##
      # Returns true if JSON object has nested attributes.
      #
      def nested?
        key.present?
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
        tags = normalize_tags tag_or_tags

        ArrayJsonb::Create.new.call repository: self,
                                    relation: klass,
                                    tags: tags,
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
        tag = normalize_one_tag tag
        new_tag = normalize_one_tag new_tag

        ArrayJsonb::Update.new.call repository: self,
                                    relation: klass,
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
        tags = normalize_tags tag_or_tags
        relation = klass.where(column_name => PgTagsOn.query_class.any(tag_or_tags))

        ArrayJsonb::Delete.new.call repository: self,
                                    relation: relation,
                                    tags: tags,
                                    returning: returning
      end

      def normalize_tags(tags)
        return normalize_one_tag(tags) unless tags.is_a?(Array)

        tags.map { |t| normalize_one_tag(t) }
      end

      def normalize_one_tag(tag)
        return tag unless nested?
        return { key => tag } unless key.is_a?(Array)

        key.reverse.inject(tag) { |a, k| { k => a } }
      end

      ##
      # @return [Arel::SelectManager]
      #
      def select_tags
        return super unless nested?

        klass
          .select(arel_distinct(extract_tag_by_path).as(tag_alias))
          .arel
      end

      ##
      # @return [Arel::SelectManager]
      #
      def select_taggings
        return super unless nested?

        klass
          .select(extract_tag_by_path.as(tag_alias),
                  arel_table['id'].as('entity_id'))
          .arel
      end

      def tag_path_array
        @tag_path_array ||= Array.wrap(key).map { |k| Arel.sql("'#{k}'") }
      end

      def extract_tag_by_path
        arel_jsonb_extract_path arel_unnest(arel_column), *tag_path_array
      end
    end
  end
end
