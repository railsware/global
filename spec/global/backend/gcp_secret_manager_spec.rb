# frozen_string_literal: true

require 'google/cloud/secret_manager'
require 'google/cloud/secret_manager/v1'
require 'global/backend/gcp_secret_manager'

RSpec.describe Global::Backend::GcpSecretManager do
  subject(:secret_manager) do
    described_class.new(prefix: 'prod-myapp-', client: client, project_id: 'example')
  end

  let(:client) { instance_double(Google::Cloud::SecretManager::V1::SecretManagerService::Client) }

  before do
    # rubocop:disable RSpec/VerifiedDoubles
    match_item = double(name: 'prod-myapp-example-test_key')
    not_match_item = double(name: 'different_key')

    secret_data = double(data: 'secret value')
    secret_version_response = double(payload: secret_data)

    page = instance_double(Gapic::PagedEnumerable)
    allow(page).to receive(:next_page_token).and_return('')
    allow(page).to receive(:each).and_yield(match_item).and_yield(not_match_item)

    allow(client).to receive(:secret_version_path)
      .with(project: 'example', secret: 'prod-myapp-example-test_key', secret_version: 'latest')
      .and_return('some_key_path')
    allow(client).to receive(:access_secret_version).with(name: 'some_key_path').and_return(secret_version_response)
    allow(client).to receive_messages(project_path: 'projects/example', list_secrets: page)
    # rubocop:enable RSpec/VerifiedDoubles
  end

  it 'reads parameters from the secret manager' do
    expect(secret_manager.load).to eq({ example: { test_key: 'secret value' }})
  end
end
