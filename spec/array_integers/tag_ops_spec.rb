# frozen_string_literal: true

RSpec.describe 'ArrayIntegers::TagOps' do
  before(:all) do
    Entity.pg_tags_on :tags_int
  end

  before do
    truncate && Factory.array_integers
  end

  let(:column) { :tags_int }
  let(:relation) { Entity.send(column) }

  context 'create' do
    it 'create tag' do
      relation.create(5)

      Entity.all.each do |entity|
        expect(entity.send(column)).to include(5)
      end
    end

    it 'create multiple tags once' do
      relation.create([100, 101])

      Entity.all.each do |entity|
        expect(entity.send(column)).to include(100)
        expect(entity.send(column)).to include(101)
      end
    end

    it 'create tag for filtered records' do
      Entity.where(attr: 'test2').send(column).create(6)

      expect(Entity.find_by_attr('test1').send(column)).not_to include(6)
      expect(Entity.find_by_attr('test2').send(column)).to include(6)
    end

    it 'create tag with returning values' do
      result = relation.create(100, returning: 'tags_int')

      expect(result).to be_a(Array)
      expect(result.size).to be_eql(4)
    end
  end

  context 'update' do
    it 'update tag' do
      relation.update(2, 22)

      count = Entity.where(column => Tags.all(22)).count
      expect(count).to be_eql(2)
    end

    it 'update tag for filtered records' do
      Entity.where(attr: 'test2', column => PgTagsOn.query_class.one(3)).send(column).update(3, 33)

      count = Entity.where(column => Tags.all(33)).count
      expect(count).to be_eql(1)
    end

    it 'update tag with returning values' do
      result = relation.update(1, 11, returning: %w[id tags_int])

      expect(result).to be_a(Array)
      expect(result[0]).to include('{11,2,3}')
    end
  end

  context 'delete' do
    it 'delete tag' do
      relation.delete(2)

      tags = relation.all.pluck(:name)
      expect(tags).not_to include(2)
    end

    it 'delete multiple tags once' do
      relation.delete([5, 55])

      tags = relation.all.pluck(:name)
      expect(tags).not_to include(5)
      expect(tags).not_to include(55)
    end

    it 'delete tag for filtered records' do
      Entity.where(attr: 'test2').send(column).delete(3)

      expect(Entity.find_by_attr('test1').send(column)).to include(3)
      expect(Entity.find_by_attr('test2').send(column)).not_to include(3)
    end

    it 'delete tag with returning values' do
      result = relation.delete(1, returning: %w[id tags_int])

      expect(result).to be_a(Array)
      expect(result[0]).to include('{2,3}')
    end
  end
end
