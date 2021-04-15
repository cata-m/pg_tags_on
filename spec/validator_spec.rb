# frozen_string_literal: true

RSpec.describe 'Validator' do
  before(:all) do
    Entity.pg_tags_on :tags_str, limit: 2, length: 3
    Entity.pg_tags_on :tags_jsonb, key: :name, limit: 2, length: 3
  end

  context 'string tags' do
    it 'add errors if number of tags exceeds limit' do
      entity = Entity.new(tags_str: %w[a b c])
      entity.valid?

      expect(entity.errors.full_messages.first).to include('size exceeded')
    end

    it 'add errors if tag length exceeds limit' do
      entity = Entity.new(tags_str: %w[a x123])
      entity.valid?

      expect(entity.errors.full_messages.first).to include('length exceeded')
    end
  end

  context 'jsonb tags' do
    it 'add errors if number of tags exceeds limit' do
      entity = Entity.new(tags_jsonb: [{ name: 'a' }, { name: 'b' }, { name: 'c' }])
      entity.valid?

      expect(entity.errors.full_messages.first).to include('size exceeded')
    end

    it 'add errors if tag length exceeds limit' do
      entity = Entity.new(tags_jsonb: [{ name: 'x123' }])
      entity.valid?

      expect(entity.errors.full_messages.first).to include('length exceeded')
    end
  end
end
