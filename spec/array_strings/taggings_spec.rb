# frozen_string_literal: true

RSpec.describe 'ArrayStrings::Taggings' do
  before(:all) do
    Entity.pg_tags_on :tags_str
    truncate && Factory.array_strings
  end

  let(:column) { :tags_str }
  let(:relation) { Entity.send(column) }

  it 'find all taggings' do
    taggings = relation.taggings.order('name')

    expect(taggings.size).to be_eql(9)
    expect(taggings.map(&:name)).to be_eql(%w[a b b c c d e e1 e2])
  end

  it 'find all taggings for filtered records' do
    taggings = Entity.where(attr: 'test2').send(column).taggings.order('name')

    expect(taggings.size).to be_eql(2)
    expect(taggings.map(&:name)).to be_eql(%w[b c])
  end
end
