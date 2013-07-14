require "spec_helper"

describe Global do
  before(:each) do
    described_class.environment = "test"
    described_class.config_directory = File.join(Dir.pwd, "spec/files")
  end

  describe ".environment" do
    subject{ described_class.environment }
    
    it{ should == "test" }

    context "when undefined" do
      before{ described_class.environment = nil }

      it{ lambda{ subject }.should raise_error("environment should be defined") }
    end
  end

  describe ".config_directory" do
    subject{ described_class.config_directory }
    
    it{ should ==  File.join(Dir.pwd, "spec/files")}

    context "when undefined" do
      before{ described_class.config_directory = nil }
      
      it{ lambda{ subject }.should raise_error("config_directory should be defined") }
    end
  end

  describe ".configuration" do
    subject{ described_class.configuration }

    it{ should be_instance_of(Global::Configuration) }

    context "when load from directory" do
      its("rspec_config.to_hash"){ should == {"default_value"=>"default value", "test_value"=>"test value"} }      
    end

    context "when load from file" do
      before{ described_class.config_directory = File.join(Dir.pwd, "spec/files/rspec_config") }
      
      its("rspec_config.to_hash"){ should == {"default_value"=>"default value", "test_value"=>"test value"} }      
    end

    context "when nested directories" do
      it{ subject.rspec["config"].to_hash.should == {"default_value"=>"default nested value", "test_value"=>"test nested value"} }
    end
  end

  describe ".method_missing" do
    context "when file exists" do
      subject{ described_class.rspec_config }

      it{ should  be_kind_of(Global::Configuration) }
    end

    context "when file does not exist" do
      subject{ described_class.some_file }

      it{ lambda{ subject }.should raise_error(NoMethodError) }
    end
  end
end
