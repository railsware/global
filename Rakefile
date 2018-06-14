# frozen_string_literal: true

require 'rubygems'
require 'bundler'

Bundler.require

require 'rspec/core/rake_task'
require 'bundler/gem_tasks'
require 'rubocop/rake_task'

RSpec::Core::RakeTask.new(:spec)
RuboCop::RakeTask.new(:rubocop) do |task|
  task.options = ['-D'] # Display cop name
  task.fail_on_error = true
end

desc 'Run all tests'
task default: %i[rubocop spec]
