# PgTagsOn

```pg_tags_on``` is a gem that makes working with tags stored in a Postgresql column easy. Supported column types are: ```character varying[]```, ```text[]```, ```integer[]``` and ```jsonb[]```.


Requirements:
* Postgresql >= 12
* Rails >= 6


Note: this gem is in early stage of development.

## Table of contents

- [Installation](#installation)
- [Usage](#usage)
  - [ActiveRecord model setup](#activerecord-model-setup)
  - [Records queries](#records-queries)
  - [Tags](#tags)
  - [Set record's tags](#set-records-tags)
  - [Configuration](#configuration)
- [Benchmarks](#benchmarks)
- [Contributing](#contributing)


## Installation

Add this line to your application's Gemfile:

```ruby
gem 'pg_tags_on'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install pg_tags_on

## Usage
### ActiveRecord model setup

One or multiple columns from a model can be specified:

```ruby
class Entity < ActiveRecord::Base
  pg_tags_on :tags
  pg_tags_on :other_tags
end
```

Validations for max. number of tags and max. tag length can be added and errors will be injected into model's ```errors``` object.


```ruby
class Entity < ActiveRecord::Base
  pg_tags_on :tags, limit: 10, tag_length: 50 # limit to 10 tags and 50 chars. per tag.
end
```

For ```jsonb[]``` you'll have to specify the key for the tag value. If you store multiple attributes in the objects then you must set also ```has_attributes: true```.

```ruby
class Entity < ActiveRecord::Base
  pg_tags_on :tags, key: :tag                             # => [{tag: 'alpha'}, {tag: 'beta'}]
  pg_tags_on :other_tags, key: :tag, has_attributes: true # => [{tag: 'alpha', created_by: 'mike', ...}, {tag: 'beta', created_by: 'john', ...}]
end
```

### Records Queries
```pg_tags_on``` registers ```Tags``` class in model's predicate builder, so you can filter the records by tags as you are usually doing in Rails. Class name can be changed if you have conflicts or you don't like it, see the [configuration](#configuration) section.

* Find records by tag:

```ruby
Entity.where(tags: Tags.one('alpha'))
```

* Find records that have exact same tags as the list, order is not important:

```ruby
Entity.where(tags: Tags.eq('alpha', 'beta', 'gamma')) # Array argument is allowed, too
```

* Find records that includes all the tags from the list:

```ruby
Entity.where(tags: Tags.all('alpha', 'beta', 'gamma')) # Array argument is allowed, too
```

* Find records that includes any tag from the list:

```ruby
Entity.where(tags: Tags.any('alpha', 'beta', 'gamma')) # Array argument is allowed, too
```

* Find records that have all the tags included in the list:

```ruby
Entity.where(tags: Tags.in('alpha', 'beta', 'gamma')) # Array argument is allowed, too
```

All the above queries supports negation operator. Example:

```ruby
Entity.where.not(tags: Tags.one('alpha'))
```

### Tags
```pg_tags_on``` creates a proxy at the class level, with the same name as the column, that can be used to query or do operations on tags.

Tags queries:

```ruby
Entity.tags.all
  => [#<PgTagsOn::Tag name: "alpha">, #<PgTagsOn::Tag name: "beta">, ... ]

Entity.tags.all_with_counts
=> [#<PgTagsOn::Tag name: "alpha", count: 10>, #<PgTagsOn::Tag name: "beta", count: 20>, ... ]

Entity.tags.count
=> 123

# filters can be applied

Entity.where(...).tags.all.where('name ilike ?', 'alp%')
=> [#<PgTagsOn::Tag name: "alpha">, #<PgTagsOn::Tag name: "alpine">, ... ]

Entity.where(...).tags.all_with_counts.where('name ilike ?', 'alp%')
=> [#<PgTagsOn::Tag name: "alpha", count: 10>, #<PgTagsOn::Tag name: "alpine", count: 20>, ... ]

```

Taggings:

```ruby
Entity.tags.taggings
  => [#<PgTagsOn::Tag name: "alpha", entity_id: 1>, #<PgTagsOn::Tag name: "beta", entity_id: 1>, #<PgTagsOn::Tag name: "alpha", entity_id: 2>, ... ]
```

Create, update and delete methods are using, for performance reasons, Postgresql functions to manipulate the arrays, so ActiveRecord models are not instantiated. A frequent problem is to ensure uniqueness of the tags for a record, and this can be achieved at the database level by creating a before create/update row trigger.

```ruby
# create
Entity.tags.create('alpha')             # add tag to all records
Entity.where(...).tags.create('alpha')  # add tag to filtered records

# update
Entity.tags.update('alpha', 'a')             # rename tag for all records
Entity.where(...).tags.update('alpha', 'a')  # rename tag for filtered records

# delete
Entity.tags.delete('alpha')             # delete tag from all records
Entity.where(...).tags.delete('alpha')  # delete tag from filtered records
```

### Set record's tags
By default ```pg_tags_on``` does not add any logic in the way that the tags are set and saved in database. It'll let all the transformations, like lowercase, strip spaces, unique etc..., at the programmer choice.


### Configuration

You can configure ```pg_tags_on``` in an initializer ```config/initializers/pg_tags_on.rb```:

```ruby
PgTagsOn.configure do |c|
  c.query_class = 'Tagz'
end
```

### Benchmarks

```ruby
rake pg_tags_on:benchmark
```

## Contributing

1. Fork it ( http://github.com/cata-m/pg_tags_on/fork )
2. Install gem dependencies: ```bundle install```
3. Create a new feature or fix branch like: 'feature/new-feature' or 'fix/fix-some-issues'
4. Make sure all tests pass: ```bundle exec rake spec```
5. Commit your changes: git commit -am 'your changes'
6. Push to the branch
7. Create new pull request

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).

## Code of Conduct

Everyone interacting in the PgTagsOn project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/cata-m/pg_tags_on/blob/master/CODE_OF_CONDUCT.md).
