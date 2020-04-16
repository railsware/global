# frozen_string_literal: true

module Global
  module Backend
    # Loads Global configuration from the Google Cloud Secret Manager
    # https://cloud.google.com/secret-manager/docs
    #
    # This backend requires the `google-cloud-secret_manager` gem, so make sure to add it to your Gemfile.
    #
    # Available options:
    # - `project_id` (required): Google Cloud project name
    # - `prefix` (required): the prefix in Secret Manager; all parameters within the prefix will be loaded;
    #   make sure to add a undescore, if you want it
    #   see https://cloud.google.com/secret-manager/docs/overview
    # - `client`: pass you own Google::Cloud::SecretManager instance, or alternatively set:
    # - `gcp_options`: credentials and other Google cloud configuration options
    #   that are passed to Google::Cloud::SecretManager.configure
    #   see https://googleapis.dev/ruby/google-cloud-secret_manager/latest/index.html
    #   If Google Cloud access is already configured through environment variables,
    #   you don't need to pass the credentials explicitly.
    #
    # For Rails:
    # - the `prefix` is optional and defaults to `[Rails enviroment]-[Name of the app class]-`,
    #    for example: `production-myapp-`
    # - to use a different app name, pass `app_name`,
    #    for example: `backend :gcp_secret_manager, app_name: 'new_name_for_my_app'`
    class GcpSecretManager

      GCP_SEPARATOR = '/'
      PATH_SEPARATOR = '-'

      def initialize(options = {})
        @project_id = options.fetch(:project_id)
        require_gcp_gem
        init_prefix(options)
        init_client(options)
      end

      def load
        pages = load_all_parameters_from_gcsm

        configuration = {}
        pages.each do |page|
          configuration.deep_merge!(build_configuration_from_page(page))
        end

        configuration
      end

      private

      def require_gcp_gem
        require 'google/cloud/secret_manager'
      rescue LoadError
        raise 'The `google-cloud-secret_manager` gem must be installed.'
      end

      def init_prefix(options)
        @prefix = if defined?(Rails)
                    options.fetch(:prefix) do
                      environment = Rails.env.to_s
                      app_name = options.fetch(:app_name) { Rails.application.class.module_parent_name }
                      "#{environment}-#{app_name}-"
                    end
                  else
                    options.fetch(:prefix)
                  end
      end

      def init_client(options)
        if options.key?(:client)
          @gcsm = options[:client]
        else
          gcp_options = options.fetch(:gcp_options, {})
          @gcsm = Google::Cloud::SecretManager.secret_manager_service do |config|
            config.credentials = gcp_options[:credentials] if gcp_options[:credentials]
            config.timeout = gcp_options[:timeout] if gcp_options[:timeout]
          end
        end
      end

      def load_all_parameters_from_gcsm
        response = load_parameters_from_gcsm
        all_pages = [response]
        loop do
          break if response.next_page_token.empty?

          response = load_parameters_from_gcsm(response.next_page_token)
          all_pages << response
        end

        all_pages
      end

      def load_parameters_from_gcsm(next_token = nil)
        @gcsm.list_secrets(
          parent: @gcsm.project_path(project: @project_id),
          page_size: 25_000,
          page_token: next_token
        )
      end

      # builds a nested configuration hash from the array of parameters from Secret Manager
      def build_configuration_from_page(page)
        configuration = {}

        page.each do |parameter|
          key_name = get_gcp_key_name(parameter)
          next unless key_name.start_with?(@prefix)

          parameter_parts = key_name[@prefix.length..-1].split(PATH_SEPARATOR).map(&:to_sym)
          param_container = parameter_parts[0..-2].reduce(configuration) do |container, part|
            container[part] ||= {}
          end
          param_container[parameter_parts[-1]] = get_latest_key_value(key_name)
        end

        configuration
      end

      def get_gcp_key_name(parameter)
        parameter.name.split(GCP_SEPARATOR).last
      end

      def get_latest_key_value(key_name)
        name = @gcsm.secret_version_path(
          project:        @project_id,
          secret:         key_name,
          secret_version: 'latest'
        )
        version = @gcsm.access_secret_version(name: name)
        version.payload.data
      end

    end
  end
end
