# frozen_string_literal: true

RSpec.describe 'TagsQuery' do
  it 'accept String arguments' do
    query = PgTagsOn::TagsQuery.all('a')

    expect(query.value).to be_eql('a')
    expect(query.predicate).to be_eql('all')
  end

  it 'accept Integer arguments' do
    query = PgTagsOn::TagsQuery.all(1)

    expect(query.value).to be_eql(1)
    expect(query.predicate).to be_eql('all')
  end

  it 'accept Array arguments' do
    query = PgTagsOn::TagsQuery.all(%w[a b c])

    expect(query.value).to be_eql(%w[a b c])
    expect(query.predicate).to be_eql('all')
  end

  it 'accept arguments list' do
    query = PgTagsOn::TagsQuery.all('a', 'b', 'c')

    expect(query.value).to be_eql(%w[a b c])
    expect(query.predicate).to be_eql('all')
  end
end
