# frozen_string_literal: true

lib = File.expand_path('lib', __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'pg_tags_on/version'

Gem::Specification.new do |spec|
  spec.name          = 'pg_tags_on'
  spec.version       = PgTagsOn::VERSION
  spec.authors       = ['Catalin Marinescu']
  spec.email         = ['cata.marinesq@gmail.com']
  spec.summary       = 'Query and manage tags stored in a Postgresql column.'
  spec.description   = 'A gem that makes working with tags stored in a Postgresql column easy.
                        Support for array of string, integer and jsonb values.'
  spec.homepage      = 'http://github.com/cata-m/pg_tags_on'
  spec.license       = 'MIT'

  spec.metadata = {
    'bug_tracker_uri' => 'https://github.com/cata-m/pg_tags_on/issues',
    'changelog_uri' => 'https://github.com/cata-m/pg_tags_on/blob/master/CHANGELOG.md',
    'homepage_uri' => spec.homepage,
    'source_code_uri' => 'https://github.com/cata-m/pg_tags_on'
  }

  spec.files            = Dir['lib/**/*']
  spec.extra_rdoc_files = Dir['README.md', 'CHANGELOG.md', 'LICENSE.txt']
  spec.executables      = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files       = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths    = ['lib']

  spec.required_ruby_version = '>= 2.7.0'

  spec.add_dependency 'activerecord', '~> 7.0'
  spec.add_dependency 'activesupport', '~> 7.0'
  spec.add_development_dependency 'pg', '1.2.2'
  spec.add_development_dependency 'rake', '~> 13.0'
  spec.add_development_dependency 'rspec', '~> 3.9'
end
