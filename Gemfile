source "http://rubygems.org"

# Specify your gem's dependencies in global.gemspec
gemspec

if RUBY_VERSION < "2.2.2"
  # activesupport 5+ requires MRI 2.2.2+
  gem "activesupport", "< 5.0.0"
end
