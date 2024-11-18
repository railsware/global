# frozen_string_literal: true

require 'spec_helper'
require 'aws-sdk-ssm'
require 'global/backend/aws_parameter_store'

RSpec.describe Global::Backend::AwsParameterStore do
  subject(:parameter_store) do
    described_class.new(prefix: '/testapp/', client: client)
  end

  let(:client) do
    Aws::SSM::Client.new(stub_responses: true)
  end

  it 'reads parameters from the parameter store' do # rubocop:disable RSpec/ExampleLength, RSpec/MultipleExpectations
    client.stub_responses(
      :get_parameters_by_path,
      [
        lambda { |req_context|
          expect(req_context.params[:next_token]).to be_nil
          {
            parameters: [
              { name: '/testapp/foo', value: 'foo-value' },
              { name: '/testapp/bar/baz', value: 'baz-value' }
            ],
            next_token: 'next-token'
          }
        },
        lambda { |req_context|
          expect(req_context.params[:next_token]).to eq('next-token')
          {
            parameters: [
              { name: '/testapp/bar/qux', value: 'qux-value' }
            ],
            next_token: nil
          }
        }
      ]
    )
    expect(parameter_store.load).to eq(
      foo: 'foo-value',
      bar: {
        baz: 'baz-value',
        qux: 'qux-value'
      }
    )
  end
end
