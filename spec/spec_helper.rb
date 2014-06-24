# encoding: utf-8

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$:.unshift(File.dirname(__FILE__))
require 'rspec'
require 'global'
require 'simplecov'
require 'support/javascript_helper'

SimpleCov.start do
  add_filter '/spec/'

  add_group 'Libraries', '/lib/'
end

RSpec.configure do |config|

  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.order = 'random'
  config.include JavascriptHelper
end