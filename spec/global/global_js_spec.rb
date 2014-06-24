require "spec_helper"

describe Global, "generate js in Rails"  do

  context 'simple generate' do
    before do
      described_class.configure do |config|
        config.environment = "test"
        config.config_directory = File.join(Dir.pwd, "spec/files")
        config.js_namespace = 'Global'
        config.js_except = :all
        config.js_only = :all
      end
      evaljs(described_class.generate_js)
    end

    it "should generate valid global config" do
      expect(evaljs("Global.rspec_config.default_value")).to eq('default value')
    end

    it "should generate valid global config for array" do
      expect(evaljs("Global.nested_config.some_array_value.length")).to eq(3)
    end

    it "should generate valid global config for array, first element" do
      expect(evaljs("Global.nested_config.some_array_value[0]")).to eq("First")
    end

    it "should generate valid global config for array, last element" do
      expect(evaljs("Global.nested_config.some_array_value[2]")).to eq("Third")
    end

  end

  context 'custom namespace' do
    before do
      described_class.configure do |config|
        config.environment = "test"
        config.config_directory = File.join(Dir.pwd, "spec/files")
        config.js_namespace = 'CustomGlobal'
        config.js_except = :all
        config.js_only = :all
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
      evaljs(described_class.generate_js(js_namespace: 'CustomGlobalNamespace', js_only: :all))
    end

    it "should generate valid global config" do
      expect(evaljs("CustomGlobalNamespace.rspec_config.default_value")).to eq('default value')
    end

  end

  context 'only select' do
    before do
      described_class.configure do |config|
        config.environment = "test"
        config.config_directory = File.join(Dir.pwd, "spec/files")
        config.js_namespace = 'Global'
        config.js_except = :all
        config.js_only = [:bool_config]
      end
      evaljs(described_class.generate_js)
    end

    it "should generate visible global config" do
      expect(evaljs("Global.bool_config.works")).to eq(true)
    end

    it "should have not some keys in js" do
      expect(evaljs("Global.nested_config")).to be_nil
    end

  end

  context 'except select' do
    before do
      described_class.configure do |config|
        config.environment = "test"
        config.config_directory = File.join(Dir.pwd, "spec/files")
        config.js_namespace = 'Global'
        config.js_except = [:nested_config]
        config.js_only = []
      end
      evaljs(described_class.generate_js)
    end

    it "should generate visible global config with bool_config" do
      expect(evaljs("Global.bool_config.works")).to eq(true)
    end

    it "should generate visible global config with rspec_config" do
      expect(evaljs("Global.rspec_config.default_value")).to eq('default value')
    end

    it "should have not some keys in js" do
      expect(evaljs("Global.nested_config")).to be_nil
    end

  end

end
