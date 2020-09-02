# frozen_string_literal: true

RSpec.describe 'ArrayIntegers::Taggings' do
  before(:all) do
    Entity.pg_tags_on :tags_int
    truncate && Factory.array_integers
  end

  let(:column) { :tags_int }
  let(:relation) { Entity.send(column) }

  it 'find all taggings' do
    taggings = relation.taggings.order('name')

    expect(taggings.size).to be_eql(9)
    expect(taggings.map(&:name)).to be_eql([1, 2, 2, 3, 3, 4, 5, 55, 555])
  end

  it 'find all taggings for filtered records' do
    taggings = Entity.where(attr: 'test2').send(column).taggings.order('name')

    expect(taggings.size).to be_eql(2)
    expect(taggings.map(&:name)).to be_eql([2, 3])
  end
end
