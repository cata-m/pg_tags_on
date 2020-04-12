# frozen_string_literal: true

RSpec.describe 'ArrayStrings::TagOps' do
  before(:all) do
    Entity.pg_tags_on :tags_str
  end

  before do
    truncate && Factory.array_strings
  end

  let(:column) { :tags_str }
  let(:relation) { Entity.send(column) }

  context 'create' do
    it 'create tag' do
      relation.create('new-tag1')

      Entity.all.each do |entity|
        expect(entity.send(column)).to include('new-tag1')
      end
    end

    it 'create tag for filtered records' do
      Entity.where(attr: 'test2').send(column).create('new-tag2')

      expect(Entity.find_by_attr('test1').send(column)).not_to include('new-tag2')
      expect(Entity.find_by_attr('test2').send(column)).to include('new-tag2')
    end

    it 'create tag with returning values' do
      result = relation.create('abc', returning: column)

      expect(result).to be_a(Array)
      expect(result.size).to be_eql(3)
    end
  end

  context 'update' do
    it 'update tag' do
      relation.update('b', 'updated-b')

      count = Entity.where(column => Tags.all('updated-b')).count
      expect(count).to be_eql(2)
    end

    it 'update tag for filtered records' do
      Entity.where(attr: 'test2').send(column).update('c', 'updated-c')

      count = Entity.where(column => Tags.all('updated-c')).count
      expect(count).to be_eql(1)
    end

    it 'update tag with returning values' do
      result = relation.update('d', 'updated-d', returning: column)

      expect(result).to be_a(Array)
      expect(result[0]).to include('{updated-d}')
    end
  end

  context 'delete' do
    it 'delete tag' do
      relation.delete('b')

      tags = relation.all.pluck(:name)
      expect(tags).not_to include('b')
    end

    it 'delete tag for filtered records' do
      Entity.where(attr: 'test2').send(column).delete('c')

      expect(Entity.find_by_attr('test1').send(column)).to include('c')
      expect(Entity.find_by_attr('test2').send(column)).not_to include('c')
    end

    it 'update tag with returning values' do
      result = relation.delete('d', returning: column)

      expect(result).to be_a(Array)
      expect(result[0]).to be_eql(['{}'])
    end
  end
end
