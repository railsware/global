# encoding: utf-8

require 'forwardable'

module Global
  class Configuration
    extend Forwardable

    attr_reader :hash

    def_delegators :hash, :to_hash, :key?, :[], :[]=, :inspect


    def initialize(hash)
      @hash = hash.respond_to?(:with_indifferent_access) ? hash.with_indifferent_access : hash
    end

    def full_hash(options = {})
      hash_result = hash.map do |k,v|
        case v
        when ::Global::Configuration
          [k, v.full_hash]
        else
          [k, v]
        end
      end
      Hash[hash_result]
    end

    protected

    def method_missing(method, *args, &block)
      method = method.to_s[0..-2] if method.to_s[-1] == '?'
      if key?(method)
        value = hash[method]
        value.kind_of?(Hash) ? Global::Configuration.new(value) : value
      else
        super
      end
    end
  end
end