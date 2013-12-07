require "spec_helper"

describe Global::Configuration do
  let(:hash){ { "key" => "value", "nested" => { "key" => "value" } } }
  let(:configuration){ described_class.new hash }

  describe "#hash" do
    subject{ configuration.hash }

    it{ should == hash }
  end

  describe "#to_hash" do
    subject{ configuration.to_hash }

    it{ should == hash }
  end

  describe "key?" do
    subject{ configuration.key?(:key) }

    it{ should be_true }
  end

  describe "#[]" do
    subject{ configuration[:key] }

    it{ should == "value" }
  end

  describe "#[]=" do
    subject{ configuration[:new_key] }

    before{ configuration[:new_key] = "new_value" }

    it{ should == "new_value" }
  end

  describe "#inspect" do
    subject{ configuration.inspect }

    it{ should == hash.inspect }
  end

  describe "#method_missing" do
    context "when key exist" do
      subject{ configuration.key }

      it{ should == "value" }
    end

    context "when key does not exist" do
      subject{ configuration.some_key }

      it{ lambda { subject }.should raise_error(NoMethodError) }
    end

    context "with nested hash" do
      subject{ configuration.nested.key }

      it{ should == "value" }
    end
  end
end