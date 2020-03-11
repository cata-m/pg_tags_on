# frozen_string_literal: true

RSpec.describe 'ArrayStrings::TagOps' do
  before(:all) do
    @column = :tags_str # defined as instance var as it is used in before_all callback
    Entity.pg_tags_on @column
  end

  before do
    truncate && Factory.array_strings
  end

  let(:column) { @column }
  let(:ref) { %("#{Entity.table_name}"."#{column}") }
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
  end
end
