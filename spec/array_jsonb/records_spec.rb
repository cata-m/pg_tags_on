# frozen_string_literal: true

RSpec.describe 'ArrayJsonb::Records' do
  let(:column) { :tags_jsonb }
  let(:ref) { %("#{Entity.table_name}"."#{column}") }

  context 'objects have only one key' do
    before(:all) do
      Entity.pg_tags_on :tags_jsonb, key: :name
      truncate && Factory.array_jsonb
    end

    it 'find records by tag' do
      rel = Entity.where(column => Tags.one('b'))
      expected_sql = %(#{ref} @> #{encode_json([{ name: 'b' }])})

      expect(rel.to_sql).to include(expected_sql)
      expect(rel.count).to be_eql(2)
    end

    it 'find records with exact same tags' do
      rel = Entity.where(column => Tags.eq(%w[b c]))

      expect(rel.count).to be_eql(1)
    end

    it 'find records with all tags' do
      rel = Entity.where(column => Tags.all(%w[a b c]))
      expected_sql = %(#{ref} @> #{encode_json([{ name: 'a' }, { name: 'b' }, { name: 'c' }])})

      expect(rel.to_sql).to include(expected_sql)
      expect(rel.count).to be_eql(1)
    end

    it 'find records with any tags' do
      rel = Entity.where(column => Tags.any(%w[a b c]))
      expected_sql = %(#{ref} && #{encode_json([{ name: 'a' }, { name: 'b' }, { name: 'c' }])})

      expect(rel.to_sql).to include(expected_sql)
      expect(rel.count).to be_eql(2)
    end

    it 'find records with tags included in tag list' do
      rel = Entity.where(column => Tags.in(%w[a b c]))
      expected_sql = %(#{ref} <@ #{encode_json([{ name: 'a' }, { name: 'b' }, { name: 'c' }])})

      expect(rel.to_sql).to include(expected_sql)
      expect(rel.count).to be_eql(2)
    end
  end

  context 'objects have multiple keys' do
    before(:all) do
      Entity.pg_tags_on :tags_jsonb, key: :name, has_attributes: true
      truncate && Factory.array_jsonb_with_attrs
    end

    it 'find records by tag' do
      rel = Entity.where(column => Tags.one('b'))
      expect(rel.count).to be_eql(2)
    end

    it 'find records with exact same tags' do
      rel = Entity.where(column => Tags.eq(%w[b c]))

      expect(rel.count).to be_eql(1)
    end

    it 'find records with all tags' do
      rel = Entity.where(column => Tags.all(%w[a b c]))
      expect(rel.count).to be_eql(1)
    end

    it 'find records with any tags' do
      rel = Entity.where(column => Tags.any(%w[a b c]))
      expect(rel.count).to be_eql(2)
    end

    it 'find records with tags included in tag list' do
      rel = Entity.where(column => Tags.in(%w[a b c]))
      expect(rel.count).to be_eql(2)
    end
  end
end
