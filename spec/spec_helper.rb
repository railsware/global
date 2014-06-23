# encoding: utf-8

$:.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))
$:.unshift(File.dirname(__FILE__))
require 'rspec'
require 'global'
require 'simplecov'

if defined?(JRUBY_VERSION)
  require 'rhino'
  JS_LIB_CLASS = Rhino
else
  require 'v8'
  JS_LIB_CLASS = V8
end

def jscontext(force = false)
  if force
    @jscontext = JS_LIB_CLASS::Context.new
  else
    @jscontext ||= JS_LIB_CLASS::Context.new
  end
end

def js_error_class
  JS_LIB_CLASS::JSError
end

def evaljs(string, force = false)
  jscontext(force).eval(string)
end

SimpleCov.start do
  add_filter '/spec/'

  add_group 'Libraries', '/lib/'
end

RSpec.configure do |config|

  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.order = 'random'

  config.before :each do
    evaljs("var window = this;", true)
    jscontext[:log] = lambda {|context, value| puts value.inspect}
  end
end