$:.push File.expand_path("../lib", __FILE__)
require "global/version"

Gem::Specification.new do |s|
  s.name = "global"
  s.version = Global::VERSION
  s.authors = ["paladiy"]
  s.email = "olexanderpaladiy@gmail.com"

  s.rubyforge_project = "global"

  s.description = "Simple way to load your configs from yaml"
  s.summary = "Simple way to load your configs from yaml"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.homepage = "https://github.com/railsware/global"
  s.licenses = ["MIT"]

  s.add_development_dependency "rspec",     "~> 2.14.1"
  s.add_development_dependency "simplecov", "~> 0.7.1"
  s.add_development_dependency "rake",      "~> 10.1.0"

  s.add_runtime_dependency "activesupport"
end
