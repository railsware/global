# frozen_string_literal: true

require 'erb'
require 'json'

module Global
  module Base

    extend self

    def configure
      yield self
    end

    def configuration
      raise 'Backend must be defined' unless @backends

      @configuration ||= begin
        configuration_hash = @backends.reduce({}) do |configuration, backend|
          configuration.deep_merge(backend.load.with_indifferent_access)
        end
        Configuration.new(configuration_hash)
      end
    end

    def reload!
      @configuration = nil
      configuration
    end

    # Add a backend to load configuration from.
    #
    # You can define several backends; they will all be loaded
    # and the configuration hashes will be merged.
    #
    # Configure with either:
    #   Global.backend :filesystem, directory: 'config', environment: Rails.env
    # or:
    #   Global.backend YourConfigurationBackend.new
    #
    # backend configuration classes MUST have a `load` method that returns a configuration Hash
    def backend(backend, options = {})
      @backends ||= []
      if backend.is_a?(Symbol)
        require "global/backend/#{backend}"
        backend_class = Global::Backend.const_get(camel_case(backend.to_s))
        @backends.push backend_class.new(options)
      elsif backend.respond_to?(:load)
        @backends.push backend
      else
        raise 'Backend must be either a Global::Backend class or a symbol'
      end
    end

    protected

    def respond_to_missing?(method, include_private = false)
      configuration.key?(method) || super
    end

    def method_missing(method, *args, &block)
      configuration.key?(method) ? configuration.get_configuration_value(method) : super
    end

    # from Bundler::Thor::Util.camel_case
    def camel_case(str)
      return str if str !~ /_/ && str =~ /[A-Z]+.*/

      str.split('_').map(&:capitalize).join
    end

  end
end
