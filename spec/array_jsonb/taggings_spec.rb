# frozen_string_literal: true

RSpec.describe 'ArrayJsonb::Taggings' do
  before(:all) do
    @column = :tags_jsonb
    Entity.pg_tags_on @column, key: :name
    truncate && Factory.array_jsonb
  end

  let(:column) { @column }
  let(:ref) { %("#{Entity.table_name}"."#{column}") }
  let(:relation) { Entity.send(column) }

  it 'find all taggings' do
    taggings = relation.taggings.order('name')

    expect(taggings.size).to be_eql(6)
    expect(taggings.map(&:name)).to be_eql(%w[a b b c c d])
  end

  it 'find all taggings for filtered records' do
    taggings = Entity.where(attr: 'test2').send(column).taggings.order('name')

    expect(taggings.size).to be_eql(2)
    expect(taggings.map(&:name)).to be_eql(%w[b c])
  end
end
