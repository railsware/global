# frozen_string_literal: true

require 'spec_helper'
require 'aws-sdk-ssm'
require 'global/backend/aws_parameter_store'

RSpec.describe Global::Backend::AwsParameterStore do
  let(:client) do
    Aws::SSM::Client.new(stub_responses: true)
  end
  subject do
    described_class.new(prefix: '/testapp/', client: client)
  end

  it 'reads parameters from the parameter store' do
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
    expect(subject.load).to eq(
      foo: 'foo-value',
      bar: {
        baz: 'baz-value',
        qux: 'qux-value'
      }
    )
  end
end
