# frozen_string_literal: true

RSpec.describe 'ArrayJsonb::TagOps' do
  context 'objects has only one key' do
    before(:all) do
      Entity.pg_tags_on :tags_jsonb, key: :name
    end

    before do
      truncate && Factory.array_jsonb
    end

    let(:column) { :tags_jsonb }
    let(:relation) { Entity.send(column) }

    context 'create' do
      it 'create tag' do
        relation.create('new-tag1')

        Entity.all.each do |entity|
          expect(entity.send(column)).to include({ 'name' => 'new-tag1' })
        end
      end

      it 'create multiple tags once' do
        relation.create(%w[mtag1 mtag2])

        Entity.all.each do |entity|
          expect(entity.send(column)).to include({ 'name' => 'mtag1' })
          expect(entity.send(column)).to include({ 'name' => 'mtag2' })
        end
      end

      it 'create tag for filtered records' do
        Entity.where(attr: 'test2').send(column).create('new-tag2')

        expect(Entity.find_by_attr('test1').send(column)).not_to include({ 'name' => 'new-tag2' })
        expect(Entity.find_by_attr('test2').send(column)).to include({ 'name' => 'new-tag2' })
      end

      it 'create tag with returning values' do
        result = relation.create('abc', returning: column)

        expect(result).to be_a(Array)
        expect(result.size).to be_eql(4)
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
      end
    end

    context 'delete' do
      it 'delete tag' do
        relation.delete('b')

        tags = relation.all.pluck(:name)
        expect(tags).not_to include('b')
      end

      it 'deletes multiple tags once' do
        relation.delete(%w[e1 e2])

        tags = relation.all.pluck(:name)

        expect(tags).not_to include('e1')
        expect(tags).not_to include('e2')
      end

      it 'delete tag for filtered records' do
        Entity.where(attr: 'test2').send(column).delete('c')

        expect(Entity.where(attr: 'test1').send(column).all.pluck(:name)).to include('c')
        expect(Entity.where(attr: 'test2').send(column).all.pluck(:name)).not_to include('c')
      end

      it 'delete tag with returning values' do
        result = relation.delete('d', returning: column)

        expect(result).to be_a(Array)
        expect(result[0]).to include('{}')
      end
    end
  end

  context 'objects have multiple keys' do
    before(:all) do
      Entity.pg_tags_on :tags_jsonb, key: :name, has_attributes: true
    end

    before(:each) do
      truncate && Factory.array_jsonb_with_attrs
    end

    let(:column) { :tags_jsonb }
    let(:relation) { Entity.send(column) }

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
