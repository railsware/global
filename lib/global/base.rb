# frozen_string_literal: true

require 'erb'
require 'json'

module Global
  module Base

    FILE_ENV_SPLIT = '.'
    YAML_EXT = '.yml'

    extend self

    attr_writer :environment, :config_directory, :namespace, :except, :only, :yaml_whitelist_classes

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
      @environment || raise('environment should be defined')
    end

    def config_directory
      @config_directory || raise('config_directory should be defined')
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

    def yaml_whitelist_classes
      @yaml_whitelist_classes ||= []
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

      if File.exist?(file = "#{dir}#{YAML_EXT}")
        configurations = load_yml_file(file)
        config = get_config_by_key(configurations, 'default')
        config.deep_merge!(get_config_by_key(configurations, env))
        if File.exist?(env_file = "#{dir}#{FILE_ENV_SPLIT}#{env}#{YAML_EXT}")
          config.deep_merge!(load_yml_file(env_file) || {})
        end
      end

      config
    end

    def get_config_by_key(config, key)
      config[key.to_sym] || config[key.to_s] || {}
    end

    def load_yml_file(file)
      YAML.safe_load(
        ERB.new(IO.read(file)).result,
        [Date, Time, DateTime, Symbol].concat(yaml_whitelist_classes),
        [], true
      )
    end

    def load_from_directory(dir, env)
      config = {}

      if File.directory?(dir)
        Dir["#{dir}/*"].each do |entry|
          namespace = File.basename(entry, YAML_EXT)
          next if namespace.include? FILE_ENV_SPLIT # skip files with dot(s) in name
          file_with_path = File.join(File.dirname(entry), File.basename(entry, YAML_EXT))
          config.deep_merge!(namespace => load_configuration(file_with_path, env))
        end
      end

      config
    end

    def respond_to_missing?(method, include_private = false)
      configuration.key?(method) || super
    end

    def method_missing(method, *args, &block)
      configuration.key?(method) ? configuration[method] : super
    end

  end
end
