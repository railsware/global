# frozen_string_literal: true

require 'forwardable'

module Global
  class Configuration

    extend Forwardable

    attr_reader :hash

    def_delegators :hash, :key?, :has_key?, :include?,
                   :member?, :[], :[]=, :to_hash, :to_json,
                   :inspect, :fetch

    # rubocop:disable Lint/BooleanSymbol
    # @see ActiveModel::Type::Boolean::FALSE_VALUES
    FALSE_VALUES = [
      false, 0,
      '0', :'0',
      'f', :f,
      'F', :F,
      'false', :false,
      'FALSE', :FALSE,
      'off', :off,
      'OFF', :OFF
    ].to_set.freeze
    private_constant :FALSE_VALUES
    # rubocop:enable Lint/BooleanSymbol

    def initialize(hash)
      @hash = hash.respond_to?(:with_indifferent_access) ? hash.with_indifferent_access : hash
    end

    def filter(options = {})
      keys = filtered_keys_list(options)
      hash.select { |key, _| keys.include?(key) }
    end

    def get_configuration_value(key)
      return nil unless key?(key)

      value = hash[key]
      value.is_a?(Hash) ? Global::Configuration.new(value) : value
    end

    private

    def filtered_keys_list(options)
      return hash.keys - options[:except].map(&:to_s) if options[:except].is_a?(Array)
      return hash.keys & options[:only].map(&:to_s) if options[:only].is_a?(Array)

      return hash.keys if options[:only] == :all
      return [] if options[:except] == :all

      []
    end

    protected

    def respond_to_missing?(method_name, include_private = false)
      method = normalize_key_by_method(method_name)
      key?(method) || boolean_method?(method) || super
    end

    def method_missing(method, *args, &block)
      normalized_method = normalize_key_by_method(method)
      if key?(normalized_method)
        value = get_configuration_value(normalized_method)
        boolean_method?(method) ? cast_boolean(value) : value
      else
        super
      end
    end

    def boolean_method?(method)
      '?' == method.to_s[-1]
    end

    # @see ActiveModel::Type::Boolean#cast_value
    def cast_boolean(value)
      if value == '' || value.nil?
        false
      else
        !FALSE_VALUES.include?(value)
      end
    end

    def normalize_key_by_method(method)
      boolean_method?(method) ? method.to_s[0..-2].to_sym : method
    end

  end
end
