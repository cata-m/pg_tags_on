# frozen_string_literal: true

RSpec.describe 'configuration' do
  before do
    Entity.pg_tags_on_reset
  end

  it 'should set query class' do
    PgTagsOn.configure do |c|
      c.query_class = 'Tagz'
    end
    Entity.pg_tags_on :tags_int

    expect(Kernel.const_defined?('Tagz')).to be_truthy
  end

  it 'should set columns for multiple models' do
    class Entity1 < ActiveRecord::Base
      self.table_name = 'entities'
      pg_tags_on :tags_int
    end

    class Entity2 < ActiveRecord::Base
      self.table_name = 'entities'
      pg_tags_on :tags_str
    end

    expect(Entity1.pg_tags_on_settings).to be_eql('tags_int' => {})
    expect(Entity2.pg_tags_on_settings).to be_eql('tags_str' => {})
  end

  it 'should set multiple columns for the same model' do
    Entity.pg_tags_on :tags_int
    Entity.pg_tags_on :tags_str

    expect(Entity.pg_tags_on_settings).to be_eql('tags_int' => {}, 'tags_str' => {})
  end

  it 'should raise error if column does not exists' do
    expect { Entity.pg_tags_on(:dummy) }.to raise_error(PgTagsOn::ColumnNotFoundError)
  end

  it 'should create named scopes' do
    Entity.pg_tags_on :tags_int

    expect(Entity).to respond_to(:tags_int)
  end
end
