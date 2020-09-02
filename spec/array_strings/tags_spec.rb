# frozen_string_literal: true

RSpec.describe 'ArrayStrings::Tags' do
  before(:all) do
    Entity.pg_tags_on :tags_str
    truncate && Factory.array_strings
  end

  let(:column) { :tags_str }
  let(:relation) { Entity.send(column) }

  it 'find all tags' do
    tags = relation.all.order('name')

    expect(tags.size).to be_eql(7)
    expect(tags.map(&:name)).to be_eql(%w[a b c d e e1 e2])
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
    expect(relation.count).to be_eql(7)
  end

  it 'count tags for filtered records' do
    expect(Entity.where(attr: 'test2').send(column).count).to be_eql(2)
  end

  context 'cast integers to strings' do
    before do
      Entity.create(attr: 'int1', column => [1])
    end

    it 'find tags in numeric format' do
      tags = relation.all.where(name: 1)

      expect(tags.size).to be_eql(1)
      expect(tags.map(&:name)).to be_eql(['1'])
    end
  end
end
