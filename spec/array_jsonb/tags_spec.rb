# frozen_string_literal: true

RSpec.describe 'ArrayJsonb::Tags' do
  before(:all) do
    @column = :tags_jsonb
    Entity.pg_tags_on @column, key: :name
    truncate && Factory.array_jsonb
  end

  let(:column) { @column }
  let(:ref) { %("#{Entity.table_name}"."#{column}") }
  let(:relation) { Entity.send(column) }

  it 'find all tags' do
    tags = relation.all.order('name')

    expect(tags.size).to be_eql(4)
    expect(tags.map(&:name)).to be_eql(%w[a b c d])
  end

  it 'find all tags for filtered records' do
    tags = Entity.where(attr: 'test2').send(column).all

    expect(tags.size).to be_eql(2)
    expect(tags.map(&:name)).to be_eql(%w[b c])
  end

  it 'find all tags with counts' do
    tag = relation.all_with_counts.first

    expect(tag.count).to be_eql(1)
  end

  it 'count tags' do
    expect(relation.count).to be_eql(4)
  end

  it 'count tags for filtered records' do
    expect(Entity.where(attr: 'test2').send(column).count).to be_eql(2)
  end
end
