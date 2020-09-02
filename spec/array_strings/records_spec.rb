# frozen_string_literal: true

RSpec.describe 'ArrayStrings::Records' do
  before(:all) do
    Entity.pg_tags_on :tags_str
    truncate && Factory.array_strings
  end

  let(:column) { :tags_str }
  let(:ref) { %("#{Entity.table_name}"."#{column}") }

  it 'find records by tag' do
    rel = Entity.where(column => Tags.one('b'))

    expect(rel.to_sql).to include(%(#{ref} @> '{b}'))
    expect(rel.count).to be_eql(2)
  end

  it 'find records without tag' do
    rel = Entity.where.not(column => Tags.one('b'))

    expect(rel.to_sql).to include(%(NOT (#{ref} @> '{b}')))
    expect(rel.count).to be_eql(2)
  end

  it 'find records with exact same tags' do
    rel = Entity.where(column => Tags.eq(%w[c b]))

    expect(rel.count).to be_eql(1)
  end

  it 'find records with all tags' do
    rel = Entity.where(column => Tags.all(%w[a b c]))

    expect(rel.to_sql).to include(%(#{ref} @> '{a,b,c}'))
    expect(rel.count).to be_eql(1)
  end

  it 'find records without tags' do
    rel = Entity.where.not(column => Tags.all(%w[a b]))

    expect(rel.to_sql).to include(%(NOT (#{ref} @> '{a,b}')))
    expect(rel.count).to be_eql(3)
  end

  it 'find records with any tag' do
    rel = Entity.where(column => Tags.any(%w[a b c]))

    expect(rel.to_sql).to include(%(#{ref} && '{a,b,c}'))
    expect(rel.count).to be_eql(2)
  end

  it 'find records with tags included in tag list' do
    rel = Entity.where(column => Tags.in(%w[a b c]))

    expect(rel.to_sql).to include(%(#{ref} <@ '{a,b,c}'))
    expect(rel.count).to be_eql(2)
  end
end
