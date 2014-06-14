require "spec_helper"

describe Global, "generate js in Rails"  do

  context 'simple generate' do
    before do
      described_class.configure do |config|
        config.environment = "test"
        config.config_directory = File.join(Dir.pwd, "spec/files")
        config.js_namespace = 'Global'
      end
      evaljs(described_class.generate_js)
    end

    it "should generate valid global config" do
      expect(evaljs("Global.rspec_config.default_value")).to eq('default value')
    end

    it "should generate valid global config for array" do
      expect(evaljs("Global.nested_config.some_array_value[0]")).to eq("First")
    end

    it "should generate valid global config for array" do
      expect(evaljs("Global.nested_config.some_array_value[2]")).to eq("Third")
    end

  end

  context 'custom namespace' do
    before do
      described_class.configure do |config|
        config.environment = "test"
        config.config_directory = File.join(Dir.pwd, "spec/files")
        config.js_namespace = 'CustomGlobal'
      end
      evaljs(described_class.generate_js)
    end

    it "should generate valid global config" do
      expect(evaljs("CustomGlobal.rspec_config.default_value")).to eq('default value')
    end

  end

  context 'custom namespace from function' do
    before do
      described_class.configure do |config|
        config.environment = "test"
        config.config_directory = File.join(Dir.pwd, "spec/files")
      end
      evaljs(described_class.generate_js(js_namespace: 'CustomGlobalNamespace'))
    end

    it "should generate valid global config" do
      expect(evaljs("CustomGlobalNamespace.rspec_config.default_value")).to eq('default value')
    end

  end

end
