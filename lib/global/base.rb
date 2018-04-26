# encoding: utf-8

require 'erb'
require 'json'

module Global
  module Base
    extend self

    attr_writer :environment, :config_directory, :namespace, :except, :only

    def configure
      yield self
    end

    def configuration
      @configuration ||= load_configuration(config_directory, environment)
    end

    def reload!
      @configuration = nil
      configuration
    end

    def environment
      @environment || raise("environment should be defined")
    end

    def config_directory
      @config_directory || raise("config_directory should be defined")
    end

    def namespace
      @namespace ||= 'Global'
    end

    def except
      @except ||= :all
    end

    def only
      @only ||= []
    end

    def generate_js(options = {})
      current_namespace = options[:namespace] || namespace

      js_options = { except: except, only: only }.merge(options)
      "window.#{current_namespace} = #{configuration.filter(js_options).to_json}"
    end

    protected

    def load_configuration(dir, env)
      config = load_from_file(dir, env)
      config.deep_merge!(load_from_directory(dir, env))
      Configuration.new(config)
    end

    def load_from_file(dir, env)
      config = {}

      if File.exists?(file = "#{dir}.yml")
        configurations = YAML::load(ERB.new(IO.read(file)).result)
        config = configurations[:default] || configurations["default"] || {}
        config.deep_merge!(configurations[env] || {})
      end

      config
    end

    def load_from_directory(dir, env)
      config = {}

      if File.directory?(dir)
        Dir["#{dir}/*"].each do |entry|
          namespace = entry.gsub(/^#{dir}\/?/, '').gsub(/\.yml$/, '')
          config.deep_merge!(namespace => load_configuration(entry.gsub(/\.yml$/, ''), env))
        end
      end

      config
    end
    
    def respond_to_missing?(method, include_private=false)
      configuration.key?(method) || super
    end

    def method_missing(method, *args, &block)
      configuration.key?(method) ? configuration[method] : super
    end
  end
end
