# frozen_string_literal: true

$LOAD_PATH.push File.expand_path('lib', __dir__)
require 'global/version'

Gem::Specification.new do |s|
  s.name = 'global'
  s.version = Global::VERSION
  s.required_ruby_version = '>= 3.0.0'
  s.authors = ['Railsware LLC']
  s.email = 'contact@railsware.com'
  s.description = 'Simple way to load your configs from yaml/aws/gcp'

  s.homepage = 'https://github.com/railsware/global'
  s.licenses = ['MIT']
  s.summary = 'Simple way to load your configs from yaml/aws/gcp'

  s.metadata['rubygems_mfa_required'] = 'true'

  s.files         = `git ls-files`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map { |f| File.basename(f) }
  s.require_paths = ['lib']

  s.add_dependency 'activesupport', '>= 2.0'
end
