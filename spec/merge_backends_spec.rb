# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Global do
  describe 'merging backends' do
    it 'merges data from two backends together' do
      backend_alpha = double('backend_alpha')
      allow(backend_alpha).to receive(:load).and_return(foo: 'foo', bar: 'bar-alpha')
      described_class.backend backend_alpha

      backend_beta = double('backend1')
      allow(backend_beta).to receive(:load).and_return(bar: 'bar-beta', baz: 'baz')
      described_class.backend backend_beta

      expect(described_class.configuration.to_hash).to eq(
        'foo' => 'foo',
        'bar' => 'bar-beta',
        'baz' => 'baz'
      )
    end
  end
end
