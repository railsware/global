# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Global::Configuration do
  let(:hash) { { 'key' => 'value', 'boolean_key' => true, 'nested' => { 'key' => 'value' }} }
  let(:configuration) { described_class.new hash }

  describe '#hash' do
    subject { configuration.hash }

    it { is_expected.to eq(hash) }
  end

  describe '#to_hash' do
    subject { configuration.to_hash }

    it { is_expected.to eq(hash) }
  end

  describe 'key?' do
    subject { configuration.key?(:key) }

    it { is_expected.to be_truthy }
  end

  describe 'has_key?' do
    subject { configuration.key?(:key) }

    it { is_expected.to be_truthy }
  end

  describe 'include?' do
    subject { configuration.include?(:key) }

    it { is_expected.to be_truthy }
  end

  describe 'member?' do
    subject { configuration.member?(:key) }

    it { is_expected.to be_truthy }
  end

  describe '#[]' do
    subject { configuration[:key] }

    it { is_expected.to eq('value') }
  end

  describe '#[]=' do
    subject { configuration[:new_key] }

    before { configuration[:new_key] = 'new_value' }

    it { is_expected.to eq('new_value') }
  end

  describe '#inspect' do
    subject { configuration.inspect }

    it { is_expected.to eq(hash.inspect) }
  end

  describe '#filter' do
    subject { configuration.filter(filter_options) }

    context 'when include all' do
      let(:filter_options) { { only: :all } }

      it { should == { 'key' => 'value', 'boolean_key' => true, 'nested' => { 'key' => 'value' }} }
    end

    context 'when except all' do
      let(:filter_options) { { except: :all } }

      it { should == {} }
    end

    context 'when except present' do
      let(:filter_options) { { except: %w[key] } }

      it { should == { 'boolean_key' => true, 'nested' => { 'key' => 'value' }} }
    end

    context 'when include present' do
      let(:filter_options) { { only: %w[key] } }

      it { should == { 'key' => 'value' } }
    end

    context 'when empty options' do
      let(:filter_options) { {} }

      it { should == {} }
    end
  end

  describe '#method_missing' do
    context 'when key exists' do
      subject { configuration.key }

      it { is_expected.to eq('value') }
    end

    context 'when boolean key exists' do
      subject { configuration.boolean_key? }

      it { is_expected.to eq(true) }
    end

    context 'when key does not exist' do
      subject { configuration.some_key }

      it { expect { subject }.to raise_error(NoMethodError) }
    end

    context 'when boolean key does not exist' do
      subject { configuration.some_boolean_key? }

      it { expect { subject }.to raise_error(NoMethodError) }
    end

    context 'with nested hash' do
      subject { configuration.nested.key }

      it { is_expected.to eq('value') }
    end
  end

  describe '#respond_to_missing?' do
    context 'when key exist' do
      subject { configuration.respond_to?(:key) }

      it { is_expected.to eq(true) }
    end

    context 'when key does not exist' do
      subject { configuration.respond_to?(:some_key) }

      it { is_expected.to eq(false) }
    end

    context 'with nested hash' do
      subject { configuration.nested.respond_to?(:key) }

      it { is_expected.to eq(true) }
    end

    context 'when call it by method' do
      subject { configuration.method(:key).call }

      it { is_expected.to eq('value') }
    end

    context 'when call it by method, which not exist' do
      it 'raise error' do
        expect { configuration.method(:some_key) }.to raise_error(NameError)
      end
    end
  end

end
