# frozen_string_literal: true

module Global
  module Backend
    # Loads Global configuration from the AWS Systems Manager Parameter Store
    # https://docs.aws.amazon.com/systems-manager/latest/userguide/systems-manager-parameter-store.html
    #
    # This backend requires the `aws-sdk` or `aws-sdk-ssm` gem, so make sure to add it to your Gemfile.
    #
    # Available options:
    # - `prefix` (required): the prefix in Parameter Store; all parameters within the prefix will be loaded;
    #   make sure to add a trailing slash, if you want it
    #   see https://docs.aws.amazon.com/systems-manager/latest/userguide/sysman-paramstore-su-organize.html
    # - `client`: pass you own Aws::SSM::Client instance, or alternatively set:
    # - `aws_options`: credentials and other AWS configuration options that are passed to AWS::SSM::Client.new
    #   see https://docs.aws.amazon.com/sdk-for-ruby/v3/api/Aws/SSM/Client.html#initialize-instance_method
    #   If AWS access is already configured through environment variables,
    #   you don't need to pass the credentials explicitly.
    #
    # For Rails:
    # - the `prefix` is optional and defaults to `/[Rails enviroment]/[Name of the app class]/`,
    #    for example: `/production/MyApp/`
    # - to use a different app name, pass `app_name`,
    #    for example: `backend :aws_parameter_store, app_name: 'new_name_for_my_app'`
    class AwsParameterStore

      PATH_SEPARATOR = '/'

      def initialize(options = {})
        require_aws_gem
        init_prefix(options)
        init_client(options)
      end

      def load
        build_configuration_from_parameters(load_all_parameters_from_ssm)
      end

      private

      def require_aws_gem
        require 'aws-sdk-ssm'
      rescue LoadError
        begin
          require 'aws-sdk'
        rescue LoadError
          raise 'Either the `aws-sdk-ssm` or `aws-sdk` gem must be installed.'
        end
      end

      def init_prefix(options)
        @prefix = if defined?(Rails)
                    options.fetch(:prefix) do
                      environment = Rails.env.to_s
                      app_name = options.fetch(:app_name) { Rails.application.class.module_parent_name }
                      "/#{environment}/#{app_name}/"
                    end
                  else
                    options.fetch(:prefix)
                  end
      end

      def init_client(options)
        if options.key?(:client)
          @ssm = options[:client]
        else
          aws_options = options.fetch(:aws_options, {})
          @ssm = Aws::SSM::Client.new(aws_options)
        end
      end

      def load_all_parameters_from_ssm
        response = load_parameters_from_ssm
        all_parameters = response.parameters
        loop do
          break unless response.next_token

          response = load_parameters_from_ssm(response.next_token)
          all_parameters.concat(response.parameters)
        end

        all_parameters
      end

      def load_parameters_from_ssm(next_token = nil)
        @ssm.get_parameters_by_path(
          path: @prefix,
          recursive: true,
          with_decryption: true,
          next_token: next_token
        )
      end

      # builds a nested configuration hash from the array of parameters from SSM
      def build_configuration_from_parameters(parameters)
        configuration = {}
        parameters.each do |parameter|
          parameter_parts = parameter.name[@prefix.length..-1].split(PATH_SEPARATOR).map(&:to_sym)
          param_container = parameter_parts[0..-2].reduce(configuration) do |container, part|
            container[part] ||= {}
          end
          param_container[parameter_parts[-1]] = parameter.value
        end

        configuration
      end

    end
  end
end
