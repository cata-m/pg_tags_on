# frozen_string_literal: true

module PgTagsOn
  # Performs benchmarking for a field, on an existing set of data.
  class Benchmark
    def initialize(klass, field)
      @klass = klass
      @field = field
    end

    def call
      tags = Entity.send(field).all.limit(5).pluck(:name)

      ::Benchmark.bmbm do |b|
        b.report('Tags.one') do
          Entity.where(field => Tags.one(tags.first)).all.to_a
        end
        b.report('Tags.eq') do
          Entity.where(field => Tags.eq(tags[0..1])).all.to_a
        end
        b.report('Tags.any') do
          Entity.where(field => Tags.any(tags)).all.to_a
        end
        b.report('Tags.all') do
          Entity.where(field => Tags.all(tags)).all.to_a
        end
        b.report('Tags.in') do
          Entity.where(field => Tags.in(tags)).all.to_a
        end
        b.report('Entity.tags.all') do
          Entity.send(field).all.to_a
        end
        b.report('Entity.tags.taggings') do
          Entity.send(field).taggings.all.to_a
        end
        b.report('Entity.tags.create') do
          Entity.send(field).create('new-tag')
        end
        b.report("Entity.tags.update") do
          Entity.send(field).update(tags.pop, tags[0]+tags[1])
        end
        b.report("Entity.tags.delete") do
          Entity.send(field).delete(tags.pop)
        end
      end
    end

    private

    attr_reader :klass, :field
  end
end
