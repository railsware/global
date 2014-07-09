# encoding: utf-8

module Global
  class Engine < ::Rails::Engine
    GLOBAL_JS_ASSET = 'global-js'

    initializer 'global-js.dependent_on_configs', after: "sprockets.environment" do
      if Rails.application.assets.respond_to?(:register_preprocessor)
        configs = Dir.glob("#{Global.config_directory}#{File::SEPARATOR}*.yml")
        Rails.application.assets.register_preprocessor 'application/javascript', :'global-js_dependent_on_configs' do |ctx, data|
          configs.map{ |config| ctx.depend_on(config) } if ctx.logical_path == GLOBAL_JS_ASSET
          data
        end
      end
    end
  end
end