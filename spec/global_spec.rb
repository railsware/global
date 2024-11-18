# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Global do
  let(:config_path) { File.join(Dir.pwd, 'spec/files') }

  before do
    described_class.configure do |config|
      config.backend :filesystem, path: config_path, environment: 'test'
    end
  end

  describe '.configuration' do
    subject(:configuration) { described_class.configuration }

    it { is_expected.to be_instance_of(Global::Configuration) }

    context 'when load from directory' do
      it 'loads configuration' do
        expect(configuration.rspec_config.to_hash).to eq(
          'default_value' => 'default value',
          'test_value' => 'test value'
        )
      end
    end

    context 'when load from file' do
      let(:config_path) { File.join(Dir.pwd, 'spec/files/rspec_config') }

      it 'loads configuration' do
        expect(configuration.to_hash).to eq(
          'default_value' => 'default value',
          'test_value' => 'test value'
        )
      end
    end

    context 'when nested directories' do
      it { expect(configuration.rspec['config'].to_hash).to eq('default_value' => 'default nested value', 'test_value' => 'test nested value') }
    end

    context 'when boolean' do
      it { expect(configuration.bool_config.works).to be(true) }
      it { expect(configuration.bool_config.works?).to be(true) }
    end

    describe 'environment file' do
      it { expect(configuration.aws.activated).to be(true) }
      it { expect(configuration.aws.api_key).to eq('some api key') }
      it { expect(configuration.aws.api_secret).to eq('some secret') }
    end

    describe 'skip files with dots in name' do
      it { expect(configuration['aws.test']).to be_nil }
      it { expect { configuration.fetch('aws.test') }.to raise_error(KeyError, /key not found/) }
    end
  end

  describe '.reload!' do
    subject(:reloaded_configuration) { described_class.reload! }

    before do
      described_class.configuration
      described_class.instance_variable_set('@backends', [])
      described_class.backend :filesystem, path: config_path, environment: 'development'
    end

    it 'returns configuration' do
      expect(reloaded_configuration).to be_instance_of(Global::Configuration)
    end

    it 'reloads configuration' do
      expect(reloaded_configuration.rspec_config.to_hash).to eq(
        'default_value' => 'default value',
        'test_value' => 'development value'
      )
    end
  end

  describe '.respond_to_missing?' do
    it 'responds to present config' do
      expect(described_class.respond_to?(:rspec_config)).to be(true)
    end

    it 'does not respond to missing config' do
      expect(described_class.respond_to?(:some_file)).to be(false)
    end
  end

  describe '.method_missing' do
    it 'returns configuration' do
      expect(described_class.rspec_config).to be_a(Global::Configuration)
    end

    it 'raises on missing configuration' do
      expect { described_class.some_file }.to raise_error(NoMethodError)
    end

    it 'returns config with nested hash' do
      expect(described_class.nested_config).to be_a(Global::Configuration)
    end
  end
end
