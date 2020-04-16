# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'global/version'

Gem::Specification.new do |s|
  s.name = 'global'
  s.version = Global::VERSION
  s.authors = ['Railsware LLC']
  s.email = 'contact@railsware.com'

  s.description = 'Simple way to load your configs from yaml/aws/gcp'
  s.summary = 'Simple way to load your configs from yaml/aws/gcp'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.homepage = 'https://github.com/railsware/global'
  s.licenses = ['MIT']

  s.add_development_dependency 'aws-sdk-ssm', '~> 1'
  s.add_development_dependency 'google-cloud-secret_manager', '~> 0'
  s.add_development_dependency 'rake',      '~> 12.3.1'
  s.add_development_dependency 'rspec',     '>= 3.0'
  s.add_development_dependency 'rubocop',   '~> 0.81.0'
  s.add_development_dependency 'simplecov', '~> 0.16.1'

  s.add_runtime_dependency 'activesupport', '>= 2.0'
end
