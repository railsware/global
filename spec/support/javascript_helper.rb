# frozen_string_literal: true

if defined?(JRUBY_VERSION)
  require 'rhino'
  JS_LIB_CLASS = Rhino
else
  require 'v8'
  JS_LIB_CLASS = V8
end

module JavascriptHelper

  def evaljs(string, force = false)
    jscontext(force).eval(string)
  end

  private

  def jscontext(force = false)
    if force
      @jscontext = JS_LIB_CLASS::Context.new
    else
      @jscontext ||= JS_LIB_CLASS::Context.new
    end
  end

end
