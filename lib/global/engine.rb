# encoding: utf-8
module Global
  class SprocketsExtension
    GLOBAL_JS_ASSET = 'global-js'

    def initialize(filename, &block)
      @filename = filename
      @source   = block.call
    end

    def render(context, empty_hash_wtf)
      self.class.run(@filename, @source, context)
    end

    def self.run(filename, source, context)
      if GLOBAL_JS_ASSET == context.logical_path
        configs = Dir.glob("#{Global.config_directory}#{File::SEPARATOR}*.yml")
        configs.map{ |config| context.depend_on(config) }
      end
      source
    end

    def self.call(input)
      filename = input[:filename]
      source   = input[:data]
      context  = input[:environment].context_class.new(input)

      result = run(filename, source, context)
      context.metadata.merge(data: result)
    end
  end


  class Engine < ::Rails::Engine
    require 'sprockets/version'
    v2                = Gem::Dependency.new('', ' ~> 2')
    vgte3             = Gem::Dependency.new('', ' >= 3')
    sprockets_version = Gem::Version.new(::Sprockets::VERSION).release
    initializer_args  = case sprockets_version
                          when -> (v) { v2.match?('', v) }
                            { after: "sprockets.environment" }
                          when -> (v) { vgte3.match?('', v) }
                            { after: :engines_blank_point, before: :finisher_hook }
                          else
                            raise StandardError, "Sprockets version #{sprockets_version} is not supported"
                        end

    is_running_rails = defined?(Rails) && Rails.respond_to?(:version)
    is_running_rails_32 = is_running_rails && Rails.version.match(/3\.2/)

    initializer 'global-js.dependent_on_configs', initializer_args do
      case sprockets_version
        when  -> (v) { v2.match?('', v) },
              -> (v) { vgte3.match?('', v) }

        # It seems rails 3.2 is not working if
        # `Rails.application.config.assets.configure` is used for
        # registering preprocessor
        if is_running_rails_32
          Rails.application.assets.register_preprocessor(
            "application/javascript",
            SprocketsExtension
          )
        else
          # Other rails version, assumed newer
          Rails.application.config.assets.configure do |config|
            config.register_preprocessor(
              "application/javascript",
              SprocketsExtension
            )
          end
        end
      else
        raise StandardError, "Sprockets version #{sprockets_version} is not supported"
      end
    end
  end
end
