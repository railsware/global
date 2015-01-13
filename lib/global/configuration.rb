# encoding: utf-8

require 'forwardable'

module Global
  class Configuration
    extend Forwardable

    attr_reader :hash

    def_delegators :hash, :key?, :[], :[]=, :to_hash, :to_json, :inspect


    def initialize(hash)
      @hash = hash.respond_to?(:with_indifferent_access) ? hash.with_indifferent_access : hash
    end

    def filter(options = {})
      keys = filtered_keys_list(options)
      hash.select{|key, _| keys.include?(key)}
    end

    def respond_to?(symbol, include_all=false)
      method = normalize_key_by_method(symbol)
      if key?(method)
        true
      else
        super
      end
    end

    private

    def filtered_keys_list(options)
      if options[:except].is_a?(Array)
        return hash.keys - options[:except].map(&:to_s)
      end

      if options[:only].is_a?(Array)
        return hash.keys & options[:only].map(&:to_s)
      end

      return hash.keys if options[:only] == :all
      return [] if  options[:except] == :all
      return []
    end

    protected

    def method_missing(method, *args, &block)
      method = normalize_key_by_method(method)
      if key?(method)
        value = hash[method]
        value.kind_of?(Hash) ? Global::Configuration.new(value) : value
      else
        super
      end
    end

    def normalize_key_by_method(method)
      '?' == method.to_s[-1] ? method.to_s[0..-2] : method
    end


  end
end