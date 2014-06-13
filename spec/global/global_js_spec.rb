require "spec_helper"

describe Global, "generate js in Rails"  do

  before(:each) do
    described_class.configure do |config|
      config.environment = "test"
      config.config_directory = File.join(Dir.pwd, "spec/files")
    end
    evaljs(described_class.generate_js({}))
  end

  it "should generate valid global config" do
    expect(evaljs("GlobalJs.rspec_config.default_value")).to eq('default value')
  end

  it "should generate valid global config for array" do
    expect(evaljs("GlobalJs.nested_config.some_array_value[0]")).to eq("First")
  end

  it "should generate valid global config for array" do
    expect(evaljs("GlobalJs.nested_config.some_array_value[2]")).to eq("Third")
  end

end
