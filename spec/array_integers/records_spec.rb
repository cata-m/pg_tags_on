# frozen_string_literal: true

RSpec.describe 'ArrayIntegers::Records' do
  before(:all) do
    @column = :tags_int # defined as instance var as it is used in before_all callback
    Entity.pg_tags_on @column
    truncate && Factory.array_integers
  end

  let(:column) { @column }
  let(:ref) { %("#{Entity.table_name}"."#{column}") }
  let(:relation) { Entity.send(column) }

  it 'find records by tag' do
    rel = Entity.where(column => Tags.one(2))

    expect(rel.to_sql).to include(%(#{ref} @> '{2}'))
    expect(rel.count).to be_eql(2)
  end

  it 'find records with exact same tags' do
    rel = Entity.where(column => Tags.eq(%w[3 2]))

    expect(rel.count).to be_eql(1)
  end

  it 'find records with all tags' do
    rel = Entity.where(column => Tags.all([1, 2, 3]))

    expect(rel.to_sql).to include(%(#{ref} @> '{1,2,3}'))
    expect(rel.count).to be_eql(1)
  end

  it 'find records with any tag' do
    rel = Entity.where(column => Tags.any([1, 2, 3]))

    expect(rel.to_sql).to include(%(#{ref} && '{1,2,3}'))
    expect(rel.count).to be_eql(2)
  end

  it 'find records with tags included in tag list' do
    rel = Entity.where(column => Tags.in([1, 2, 3]))

    expect(rel.to_sql).to include(%(#{ref} <@ '{1,2,3}'))
    expect(rel.count).to be_eql(2)
  end
end
