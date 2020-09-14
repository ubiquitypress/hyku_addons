# frozen_string_literal: true

RSpec.describe DataCiteEndpoint do
  subject(:endpoint) { described_class.new mode: 'test', prefix: '10.1234', username: 'user123', password: 'pass123' }

  describe '.options' do
    it 'uses the configured application settings' do
      expect(endpoint.options[:mode]).to eq 'test'
      expect(endpoint.options[:prefix]).to eq '10.1234'
      expect(endpoint.options[:username]).to eq 'user123'
      expect(endpoint.options[:password]).to eq 'pass123'
    end
  end

  describe '#ping' do
    # TODO: make this test better when #ping has a real implementation
    it 'returns true' do
      expect(endpoint.ping).to eq true
    end
  end
end
