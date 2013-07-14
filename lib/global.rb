require 'yaml'

require 'active_support/core_ext/hash/indifferent_access'
require 'active_support/core_ext/hash/deep_merge'

require "global/configuration"
require "global/base"
require "global/version"

module Global
  extend Base
end
