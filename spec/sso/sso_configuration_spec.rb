# frozen_string_literal: true

RSpec.describe HykuAddons::Sso do
  describe "Configuration" do
    let(:api_key) { ENN['WORKOS_API_KEY']}

    before do
      described_class.configure { |config| }
    end

    it "knows the api key" do
      expect(described_class.configuration.api_key).to eq(api_key)
    end

    it "knows the client_id" do
      expect(described_class.configuration.client_id).to eq(ENV['WORKOS_CLIENT_ID'])
    end

    it "knows the organisation_id" do
      expect(described_class.configuration.organisation_id).to eq(ENV['ORGANISATION_ID')
    end
  end
end
