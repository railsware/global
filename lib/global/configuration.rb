# encoding: utf-8

require 'forwardable'

module Global
  class Configuration
    extend Forwardable

    attr_reader :hash, :js_only_list, :js_except_list

    def_delegators :hash, :key?, :[], :[]=, :inspect


    def initialize(hash)
      @hash = hash.respond_to?(:with_indifferent_access) ? hash.with_indifferent_access : hash
    end

    def js_to_hash(options = {})
      unless (hash_res = return_all_for_options(options)).nil?
        return hash_res
      end
      # hash result
      hash_result = []
      # filter hash
      get_js_hash_keys(hash, options).each do |key|
        v = hash[key]
        hash_result << case v
        when ::Global::Configuration
          [key, v.to_hash]
        else
          [key, v]
        end
      end
      Hash[hash_result]
    end

    def to_hash
      hash_result = hash.map do |k,v|
        case v
        when ::Global::Configuration
          [k, v.to_hash]
        else
          [k, v]
        end
      end
      Hash[hash_result]
    end

    private

    def return_all_for_options(options)
      if :all == options[:js_except] && 0 == options[:js_only].size
        Hash.new
      # return all
      elsif :all == options[:js_only]
        to_hash
      else
        nil
      end
    end

    def get_js_hash_keys(hash, options)
      if options[:js_except].is_a?(Array)
        hash.keys - options[:js_except].map(&:to_s)
      elsif options[:js_only].is_a?(Array)
        hash.keys & options[:js_only].map(&:to_s)
      end
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