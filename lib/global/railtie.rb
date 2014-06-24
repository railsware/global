# encoding: utf-8

module Global
  class Railtie < (::Rails::VERSION::MAJOR < 4 ? ::Rails::Engine : ::Rails::Railtie)

    initializer 'global-js', after: 'sprockets.environment' do
      if Rails.application.assets.respond_to?(:register_preprocessor)
        Rails.application.assets.register_preprocessor 'application/javascript', :'global-js' do |ctx,data|
          data
        end
      end
    end
  end
end