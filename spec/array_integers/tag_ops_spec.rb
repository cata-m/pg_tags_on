# frozen_string_literal: true

RSpec.describe 'ArrayIntegers::TagOps' do
  before(:all) do
    @column = :tags_int # defined as instance var as it is used in before_all callback
    Entity.pg_tags_on @column
  end

  before do
    truncate && Factory.array_integers
  end

  let(:column) { @column }
  let(:ref) { %("#{Entity.table_name}"."#{column}") }
  let(:relation) { Entity.send(column) }

  context 'create' do
    it 'create tag' do
      relation.create(5)

      Entity.all.each do |entity|
        expect(entity.send(column)).to include(5)
      end
    end

    it 'create tag for filtered records' do
      Entity.where(attr: 'test2').send(column).create(6)

      expect(Entity.find_by_attr('test1').send(column)).not_to include(6)
      expect(Entity.find_by_attr('test2').send(column)).to include(6)
    end
  end

  context 'update' do
    it 'update tag' do
      relation.update(2, 22)

      count = Entity.where(column => Tags.all(22)).count
      expect(count).to be_eql(2)
    end

    it 'update tag for filtered records' do
      Entity.where(attr: 'test2').send(column).update(3, 33)

      count = Entity.where(column => Tags.all(33)).count
      expect(count).to be_eql(1)
    end
  end

  context 'delete' do
    it 'delete tag' do
      relation.delete(2)

      tags = relation.all.pluck(:name)
      expect(tags).not_to include(2)
    end

    it 'delete tag for filtered records' do
      Entity.where(attr: 'test2').send(column).delete(3)

      expect(Entity.find_by_attr('test1').send(column)).to include(3)
      expect(Entity.find_by_attr('test2').send(column)).not_to include(3)
    end
  end
end
