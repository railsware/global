# frozen_string_literal: true

require 'simplecov'

SimpleCov.start do
  add_filter '/spec/'

  add_group 'Libraries', '/lib/'
end

require 'global'

RSpec.configure do |config|
  config.disable_monkey_patching!

  config.expect_with :rspec do |expectations|
    expectations.syntax = :expect
    # This option will default to `true` in RSpec 4. It makes the `description`
    # and `failure_message` of custom matchers include text for helper methods
    # defined using `chain`, e.g.:
    # be_bigger_than(2).and_smaller_than(4).description
    #   # => "be bigger than 2 and smaller than 4"
    # ...rather than:
    #   # => "be bigger than 2"
    expectations.include_chain_clauses_in_custom_matcher_descriptions = true
  end

  config.mock_with :rspec do |mocks|
    # Prevents you from mocking or stubbing a method that does not exist on
    # a real object. This is generally recommended, and will default to
    # `true` in RSpec 4.
    mocks.verify_partial_doubles = true
  end

  config.run_all_when_everything_filtered = true
  config.filter_run :focus

  config.order = 'random'

  config.before do
    Global.remove_instance_variable(:@backends) if Global.instance_variable_defined?(:@backends)
    Global.remove_instance_variable(:@configuration) if Global.instance_variable_defined?(:@configuration)
  end
end
