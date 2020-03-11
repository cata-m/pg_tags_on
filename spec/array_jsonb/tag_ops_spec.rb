# frozen_string_literal: true

RSpec.describe 'ArrayJsonb::TagOps' do
  before(:all) do
    @column = :tags_jsonb
  end

  let(:column) { @column }
  let(:ref) { %("#{Entity.table_name}"."#{column}") }
  let(:relation) { Entity.send(column) }

  context 'objects has only one key' do
    before(:all) do
      Entity.pg_tags_on @column, key: :name
      truncate && Factory.array_jsonb
    end

    context 'create' do
      it 'create tag' do
        relation.create('new-tag1')

        Entity.all.each do |entity|
          expect(entity.send(column)).to include({ 'name' => 'new-tag1' })
        end
      end

      it 'create tag for filtered records' do
        Entity.where(attr: 'test2').send(column).create('new-tag2')

        expect(Entity.find_by_attr('test1').send(column)).not_to include({ 'name' => 'new-tag2' })
        expect(Entity.find_by_attr('test2').send(column)).to include({ 'name' => 'new-tag2' })
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

        expect(Entity.where(attr: 'test1').send(column).all.pluck(:name)).to include('c')
        expect(Entity.where(attr: 'test2').send(column).all.pluck(:name)).not_to include('c')
      end
    end
  end

  context 'objects have multiple keys' do
    before(:all) do
      Entity.pg_tags_on @column, key: :name, has_attributes: true
    end

    before(:each) do
      truncate && Factory.array_jsonb_with_attrs
    end

    context 'update' do
      it 'update tag' do
        relation.update('b', 'updated-b')

        rel = Entity.where(column => Tags.all('updated-b'))
        expect(rel.count).to be_eql(2)
        rel.all.each do |record|
          expect(record.tags_jsonb).to include({ 'meta' => 'b', 'name' => 'updated-b' })
        end
      end

      it 'update tag for filtered records' do
        Entity.where(attr: 'test2').send(column).update('c', 'updated-c')

        rel = Entity.where(column => Tags.all('updated-c'))
        expect(rel.count).to be_eql(1)
        rel.all.each do |record|
          expect(record.tags_jsonb).to include({ 'meta' => 'c', 'name' => 'updated-c' })
        end
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

        expect(Entity.where(attr: 'test1').send(column).all.pluck(:name)).to include('c')
        expect(Entity.where(attr: 'test2').send(column).all.pluck(:name)).not_to include('c')
      end
    end
  end
end
