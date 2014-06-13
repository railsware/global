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
    expect(evaljs("GlobalJs.rspec.config.default_value")).to eq('default nested value')
  end

end
