# frozen_string_literal: true

RSpec.describe 'ArrayIntegers::Taggings' do
  before(:all) do
    @column = :tags_int # defined as instance var as it is used in before_all callback
    Entity.pg_tags_on @column
    truncate && Factory.array_integers
  end

  let(:column) { @column }
  let(:ref) { %("#{Entity.table_name}"."#{column}") }
  let(:relation) { Entity.send(column) }

  it 'find all taggings' do
    taggings = relation.taggings.order('name')

    expect(taggings.size).to be_eql(6)
    expect(taggings.map(&:name)).to be_eql([1, 2, 2, 3, 3, 4])
  end

  it 'find all taggings for filtered records' do
    taggings = Entity.where(attr: 'test2').send(column).taggings.order('name')

    expect(taggings.size).to be_eql(2)
    expect(taggings.map(&:name)).to be_eql([2, 3])
  end
end
