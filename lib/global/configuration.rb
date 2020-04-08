# frozen_string_literal: true

require 'forwardable'

module Global
  class Configuration

    extend Forwardable

    attr_reader :hash

    def_delegators :hash, :key?, :has_key?, :include?,
                   :member?, :[], :[]=, :to_hash, :to_json,
                   :inspect, :fetch

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
      key?(method) || super
    end

    def method_missing(method, *args, &block)
      method = normalize_key_by_method(method)
      if key?(method)
        get_configuration_value(method)
      else
        super
      end
    end

    def normalize_key_by_method(method)
      '?' == method.to_s[-1] ? method.to_s[0..-2] : method
    end

  end
end
