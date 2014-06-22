# encoding: utf-8

require 'forwardable'

module Global
  class Configuration
    extend Forwardable

    attr_reader :hash, :js_only_list, :js_except_list

    def_delegators :hash, :to_hash, :key?, :[], :[]=, :inspect


    def initialize(hash)
      @hash = hash.respond_to?(:with_indifferent_access) ? hash.with_indifferent_access : hash
    end

    def full_root_hash(options = {})
      # return all
      if :all == options[:js_only]
        return full_hash
      # return empty hash
      elsif :all == options[:js_except] && 0 == options[:js_only].size
        return Hash.new
      end
      # only or except
      init_except_and_only_arrays(options)
      # filter hash
      hash_result = hash.map do |k,v|
        # check exceptions
        next if must_skip_this_config_key?(k)
        # check
        case v
        when ::Global::Configuration
          [k, v.full_hash]
        else
          [k, v]
        end
      end
      Hash[hash_result.compact]
    end

    def full_hash
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

    private

    def init_except_and_only_arrays(options)
      @js_only_list = (options[:js_only] && options[:js_only].is_a?(Array) ? options[:js_only] : [])
      @js_except_list = (options[:js_except] && options[:js_except].is_a?(Array) ? options[:js_except] : [])
    end

    def must_skip_this_config_key?(k)
      (js_except_list.size > 0 &&
        (js_except_list.include?(k.to_sym) || js_except_list.include?(k.to_s))
      ) ||
      (js_only_list.size > 0 &&
        (!js_only_list.include?(k.to_sym) && !js_only_list.include?(k.to_s))
      )
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