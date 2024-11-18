# frozen_string_literal: true

require 'spec_helper'

RSpec.describe Global do
  subject(:global) { described_class }

  describe 'merging backends' do
    # rubocop:disable RSpec/VerifiedDoubles
    let(:backend_alpha) { double('backend_alpha', load: { foo: 'foo', bar: 'bar-alpha' }) }
    let(:backend_beta) { double('backend_beta', load: { 'bar' => 'bar-beta', 'baz' => 'baz' }) }
    # rubocop:enable RSpec/VerifiedDoubles

    before do
      global.backend backend_alpha
      global.backend backend_beta
    end

    it 'merges data from two backends together' do
      expect(global.configuration.to_hash).to eq(
        'foo' => 'foo',
        'bar' => 'bar-beta',
        'baz' => 'baz'
      )
    end
  end
end
