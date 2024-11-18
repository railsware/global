# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Global::Configuration do
  subject(:configuration) { described_class.new hash }

  let(:hash) { { 'key' => 'value', 'boolean_key' => true, 'nested' => { 'key' => 'value' }} }

  describe '#hash' do
    it { expect(configuration.hash).to eq(hash) }
  end

  describe '#to_hash' do
    it { expect(configuration.to_hash).to eq(hash) }
  end

  describe '#key?' do
    it { expect(configuration.key?(:key)).to be(true) }
  end

  describe '#has_key?' do
    it { expect(configuration).to have_key(:key) }
  end

  describe 'include?' do
    it { expect(configuration.include?(:key)).to be(true) }
  end

  describe 'member?' do
    it { expect(configuration.member?(:key)).to be(true) }
  end

  describe '#[]' do
    it { expect(configuration[:key]).to eq('value') }
  end

  describe '#[]=' do
    it 'sets new value' do
      configuration[:new_key] = 'new_value'
      expect(configuration[:new_key]).to eq('new_value')
    end
  end

  describe '#inspect' do
    it { expect(configuration.inspect).to eq(hash.inspect) }
  end

  describe '#filter' do
    subject(:filter) { configuration.filter(filter_options) }

    context 'when include all' do
      let(:filter_options) { { only: :all } }

      it { expect(filter).to eq('key' => 'value', 'boolean_key' => true, 'nested' => { 'key' => 'value' }) }
    end

    context 'when except all' do
      let(:filter_options) { { except: :all } }

      it { expect(filter).to eq({}) }
    end

    context 'when except present' do
      let(:filter_options) { { except: %w[key] } }

      it { expect(filter).to eq('boolean_key' => true, 'nested' => { 'key' => 'value' }) }
    end

    context 'when include present' do
      let(:filter_options) { { only: %w[key] } }

      it { expect(filter).to eq('key' => 'value') }
    end

    context 'when empty options' do
      let(:filter_options) { {} }

      it { expect(filter).to eq({}) }
    end
  end

  describe '#method_missing' do
    it 'returns key value' do
      expect(configuration.key).to eq('value')
    end

    it 'returns boolean key value' do
      expect(configuration.boolean_key?).to be(true)
    end

    it 'raises on missing key' do
      expect { configuration.some_key }.to raise_error(NoMethodError)
    end

    it 'raises on missing boolean key' do
      expect { configuration.some_boolean_key? }.to raise_error(NoMethodError)
    end

    it 'returns nested key value' do
      expect(configuration.nested.key).to eq('value')
    end
  end

  describe '#respond_to_missing?' do
    it 'responds to key' do
      expect(configuration.respond_to?(:key)).to be(true)
    end

    it 'does not respond to unknown key' do
      expect(configuration.respond_to?(:some_key)).to be(false)
    end

    it 'responds to nested key' do
      expect(configuration.nested.respond_to?(:key)).to be(true)
    end

    it 'calls a method' do
      expect(configuration.method(:key).call).to eq('value')
    end

    it 'raised on a missing method call' do
      expect { configuration.method(:some_key) }.to raise_error(NameError)
    end
  end
end
