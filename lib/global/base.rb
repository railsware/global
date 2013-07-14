require "erb"

module Global
  module Base
    def configuration(env = nil)
      @configuration = nil if env
      @configuration ||= load_configuration(config_directory, env.is_a?(String) ? env : environment)
    end

    def environment=(env)
      @environment = env
    end
    
    def config_directory=(dir)
      @config_directory = dir
    end

    def environment
      @environment || raise("environment should be defined")
    end

    def config_directory
      @config_directory || raise("config_directory should be defined")
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
        config = configurations[:default] || {}
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
    
    def method_missing(method, *args, &block)
      configuration.key?(method) ? configuration[method] : super
    end
  end
end