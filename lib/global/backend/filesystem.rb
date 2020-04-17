# frozen_string_literal: true

module Global
  module Backend
    # Loads Global configuration from the filesystem
    #
    # Available options:
    # - `path` (required): the directory with config files
    # - `environment` (required): the environment to load
    # - `yaml_whitelist_classes`: the set of classes that are permitted to unmarshal from the configuration files
    #
    # For Rails:
    # - the `path` is optional and defaults to `config/global`
    # - the `environment` is optional and defaults to the current Rails environment
    class Filesystem

      FILE_ENV_SPLIT = '.'
      YAML_EXT = '.yml'

      def initialize(options = {})
        if defined?(Rails)
          @path = options.fetch(:path) { Rails.root.join('config', 'global').to_s }
          @environment = options.fetch(:environment) { Rails.env.to_s }
        else
          @path = options.fetch(:path)
          @environment = options.fetch(:environment)
        end
        @yaml_whitelist_classes = options.fetch(:yaml_whitelist_classes, [])
      end

      def load
        load_from_path(@path)
      end

      private

      def load_from_path(path)
        load_from_file(path).deep_merge(load_from_directory(path))
      end

      def load_from_file(path)
        config = {}

        if File.exist?(file = "#{path}#{YAML_EXT}")
          configurations = load_yml_file(file)
          config = get_config_by_key(configurations, 'default')
          config.deep_merge!(get_config_by_key(configurations, @environment))
          if File.exist?(env_file = "#{path}#{FILE_ENV_SPLIT}#{@environment}#{YAML_EXT}")
            config.deep_merge!(load_yml_file(env_file) || {})
          end
        end

        config
      end

      def get_config_by_key(config, key)
        return {} if config.empty?

        config[key.to_sym] || config[key.to_s] || {}
      end

      def load_yml_file(file)
        YAML.safe_load(
          ERB.new(IO.read(file)).result,
          [Date, Time, DateTime, Symbol].concat(@yaml_whitelist_classes),
          [], true
        )
      end

      def load_from_directory(path)
        config = {}

        if File.directory?(path)
          Dir["#{path}/*"].each do |entry|
            namespace = File.basename(entry, YAML_EXT)
            next if namespace.include? FILE_ENV_SPLIT # skip files with dot(s) in name

            file_with_path = File.join(File.dirname(entry), File.basename(entry, YAML_EXT))
            config.deep_merge!(namespace => load_from_path(file_with_path))
          end
        end

        config
      end

    end
  end
end
