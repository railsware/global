# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Global do

  let(:config_path) { File.join(Dir.pwd, 'spec/files') }
  before(:each) do
    described_class.configure do |config|
      config.backend :filesystem, path: config_path, environment: 'test'
    end
  end

  describe '.configuration' do
    subject { described_class.configuration }

    it { is_expected.to be_instance_of(Global::Configuration) }

    context 'when load from directory' do
      describe '#rspec_config' do
        subject { super().rspec_config }
        describe '#to_hash' do
          subject { super().to_hash }
          it { is_expected.to eq('default_value' => 'default value', 'test_value' => 'test value') }
        end
      end
    end

    context 'when load from file' do
      let(:config_path) { File.join(Dir.pwd, 'spec/files/rspec_config') }

      describe '#rspec_config' do
        describe '#to_hash' do
          subject { super().to_hash }
          it { is_expected.to eq('default_value' => 'default value', 'test_value' => 'test value') }
        end
      end
    end

    context 'when nested directories' do
      it { expect(subject.rspec['config'].to_hash).to eq('default_value' => 'default nested value', 'test_value' => 'test nested value') }
    end

    context 'when boolean' do
      it { expect(subject.bool_config.works).to eq(true) }
      it { expect(subject.bool_config.works?).to eq(true) }
    end

    context 'environment file' do
      it { expect(subject.aws.activated).to eq(true) }
      it { expect(subject.aws.api_key).to eq('some api key') }
      it { expect(subject.aws.api_secret).to eq('some secret') }
    end

    context 'skip files with dots in name' do
      it { expect(subject['aws.test']).to eq(nil) }
      it { expect { subject.fetch('aws.test') }.to raise_error(KeyError, /key not found/) }
    end
  end

  context '.reload!' do
    subject { described_class.reload! }

    before do
      described_class.configuration
      described_class.instance_variable_set('@backends', [])
      described_class.backend :filesystem, path: config_path, environment: 'development'
    end

    it { is_expected.to be_instance_of(Global::Configuration) }

    describe '#rspec_config' do
      subject { super().rspec_config }
      describe '#to_hash' do
        subject { super().to_hash }
        it { is_expected.to eq('default_value' => 'default value', 'test_value' => 'development value') }
      end
    end
  end

  describe '.respond_to_missing?' do
    context 'when file exists' do
      subject { described_class.respond_to?(:rspec_config) }

      it { is_expected.to be_truthy }
    end

    context 'when file does not exist' do
      subject { described_class.respond_to?(:some_file) }

      it { is_expected.to be_falsey }
    end
  end

  describe '.method_missing' do
    context 'when file exists' do
      subject { described_class.rspec_config }

      it { is_expected.to be_kind_of(Global::Configuration) }
    end

    context 'when file does not exist' do
      subject { described_class.some_file }

      it { expect { subject }.to raise_error(NoMethodError) }
    end

    context 'when file with nested hash' do
      subject { described_class.nested_config }

      it { is_expected.to be_kind_of(Global::Configuration) }
    end

  end
end
