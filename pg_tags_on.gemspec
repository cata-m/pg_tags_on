# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pg_tags_on/version'

Gem::Specification.new do |spec|
  spec.name          = 'pg_tags_on'
  spec.version       = PgTagsOn::VERSION
  spec.authors       = ['Catalin Marinescu']
  spec.email         = ['catalin.marinescu@gmail.com']
  spec.summary       = 'Manage tags stored in Postgresql column.'
  spec.description   = 'A gem that makes working with tags stored in a Postgresql column easy.
                        Support for array of string, integer and jsonb values.'
  spec.homepage      = 'http://github.com/cata-m/pg_tags_on'
  spec.license       = 'MIT'
  spec.metadata['homepage_uri'] = spec.homepage
  spec.metadata['source_code_uri'] = 'http://github.com/cata-m/pg_tags_on'
  spec.metadata['changelog_uri'] = 'http://github.com/cata-m/pg_tags_on/blob/master/CHANGELOG.md'

  # Specify which files should be added to the gem when it is released.
  # The `git ls-files -z` loads the files in the RubyGem that have been added into git.
  spec.files         = `git ls-files -z`.split("\x0")
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_dependency 'activerecord', '~> 6.0'
  spec.add_dependency 'activesupport', '~> 6.0'

  spec.add_development_dependency 'bundler', '~> 2.0'
  spec.add_development_dependency 'faker', '~> 2.10'
  spec.add_development_dependency 'pg', '~> 1.2'
  spec.add_development_dependency 'pry', '~> 0.12'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.9'
  spec.add_development_dependency 'rubocop', '~> 0.80'
  spec.add_development_dependency 'simplecov', '~> 0.18'
end
