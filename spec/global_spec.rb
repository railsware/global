require "spec_helper"

RSpec.describe Global do

  before(:each) do
    described_class.configure do |config|
      config.environment = "test"
      config.config_directory = File.join(Dir.pwd, "spec/files")
    end
  end

  describe ".environment" do
    subject{ described_class.environment }

    it{ is_expected.to eq("test") }

    context "when undefined" do
      before{ described_class.environment = nil }

      it{ expect{ subject }.to raise_error("environment should be defined") }
    end
  end

  describe ".config_directory" do
    subject{ described_class.config_directory }

    it{ is_expected.to eq(File.join(Dir.pwd, "spec/files"))}

    context "when undefined" do
      before{ described_class.config_directory = nil }

      it{ expect{ subject }.to raise_error("config_directory should be defined") }
    end
  end

  describe ".configuration" do
    subject{ described_class.configuration }

    it{ is_expected.to be_instance_of(Global::Configuration) }

    context "when load from directory" do
      describe '#rspec_config' do
        subject { super().rspec_config }
        describe '#to_hash' do
          subject { super().to_hash }
          it { is_expected.to eq({"default_value"=>"default value", "test_value"=>"test value"}) }
        end
      end
    end

    context "when load from file" do
      before{ described_class.config_directory = File.join(Dir.pwd, "spec/files/rspec_config") }

      describe '#rspec_config' do
        subject { super().rspec_config }
        describe '#to_hash' do
          subject { super().to_hash }
          it { is_expected.to eq({"default_value"=>"default value", "test_value"=>"test value"}) }
        end
      end
    end

    context "when nested directories" do
      it{ expect(subject.rspec["config"].to_hash).to eq({"default_value"=>"default nested value", "test_value"=>"test nested value"}) }
    end

    context "when boolean" do
      it{ expect(subject.bool_config.works).to eq(true) }
      it{ expect(subject.bool_config.works?).to eq(true) }
    end
  end

  context ".reload!" do
    subject{ described_class.reload! }

    before do
      described_class.configuration
      described_class.environment = "development"
    end

    after do
      described_class.environment = "test"
      described_class.reload!
    end

    it{ is_expected.to be_instance_of(Global::Configuration) }

    describe '#rspec_config' do
      subject { super().rspec_config }
      describe '#to_hash' do
        subject { super().to_hash }
        it { is_expected.to eq({"default_value"=>"default value", "test_value"=>"development value"}) }
      end
    end
  end
  
  describe ".respond_to_missing?" do
    context "when file exists" do
      subject{ described_class.respond_to?(:rspec_config) }

      it{ is_expected.to be_truthy }
    end

    context "when file does not exist" do
      subject{ described_class.respond_to?(:some_file) }

      it{ is_expected.to be_falsey }
    end
  end

  describe ".method_missing" do
    context "when file exists" do
      subject{ described_class.rspec_config }

      it{ is_expected.to  be_kind_of(Global::Configuration) }
    end

    context "when file does not exist" do
      subject{ described_class.some_file }

      it{ expect{ subject }.to raise_error(NoMethodError) }
    end

    context "when file with nested hash" do
      subject{ described_class.nested_config }

      it{ is_expected.to be_kind_of(Global::Configuration) }
    end

  end

end
