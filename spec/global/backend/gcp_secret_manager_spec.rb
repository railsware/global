# frozen_string_literal: true

require 'spec_helper'
require 'google/cloud/secret_manager'
require 'global/backend/gcp_secret_manager'

RSpec.describe Global::Backend::GcpSecretManager do
  let(:client) { double }

  subject do
    described_class.new(prefix: 'prod-myapp-', client: client, project_id: 'example')
  end

  before do
    @match_item = double
    allow(@match_item).to receive(:name).and_return('prod-myapp-example-test_key')

    @secret_data = double
    allow(@secret_data).to receive_message_chain(:payload, :data).and_return('secret value')

    @not_match_item = double
    allow(@not_match_item).to receive(:name).and_return('different_key')

    @list = double
    allow(@list).to receive(:next_page_token).and_return('')
    allow(@list).to receive(:each).and_yield(@match_item).and_yield(@not_match_item)

    allow(client).to receive(:project_path).and_return('projects/example')
    allow(client).to receive(:secret_version_path)
      .with(project: 'example', secret: 'prod-myapp-example-test_key', secret_version: 'latest')
      .and_return('some_key_path')
    allow(client).to receive(:access_secret_version).with(name: 'some_key_path').and_return(@secret_data)
    allow(client).to receive(:list_secrets).and_return(@list)
  end

  it 'reads parameters from the secret manager' do
    expect(subject.load).to eq({ example: { test_key: 'secret value' }})
  end
end
