require "spec_helper"

describe Global::Configuration do
  let(:hash){ { "key" => "value", "nested" => { "key" => "value" } } }
  let(:configuration){ described_class.new hash }

  describe "#hash" do
    subject{ configuration.hash }

    it{ is_expected.to eq(hash) }
  end

  describe "#to_hash" do
    subject{ configuration.to_hash }

    it{ is_expected.to eq(hash) }
  end

  describe "key?" do
    subject{ configuration.key?(:key) }

    it{ is_expected.to be_truthy }
  end

  describe "#[]" do
    subject{ configuration[:key] }

    it{ is_expected.to eq("value") }
  end

  describe "#[]=" do
    subject{ configuration[:new_key] }

    before{ configuration[:new_key] = "new_value" }

    it{ is_expected.to eq("new_value") }
  end

  describe "#inspect" do
    subject{ configuration.inspect }

    it{ is_expected.to eq(hash.inspect) }
  end

  describe "#method_missing" do
    context "when key exist" do
      subject{ configuration.key }

      it{ is_expected.to eq("value") }
    end

    context "when key does not exist" do
      subject{ configuration.some_key }

      it{ expect { subject }.to raise_error(NoMethodError) }
    end

    context "with nested hash" do
      subject{ configuration.nested.key }

      it{ is_expected.to eq("value") }
    end
  end
end