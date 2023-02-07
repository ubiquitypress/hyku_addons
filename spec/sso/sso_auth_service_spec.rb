# frozen_string_literal: true

RSpec.describe HykuAddons::Sso do
  before do
    ENV["ORGANISATION_ID"] = "org_01GP3QSZ0967S8HZ9KYWT63Y1Y"
    ENV["WORKOS_CLIENT_ID"] = "client_01GG7DRH9KVK3QNX2S6RGWA3CQ"
    ENV["WORKOS_API_KEY"] = "sk_test_a2V5XzAxR0c3RFJIOURYM0NSNUdCTjU2Q0VCTkVDLFcxUHliQWkzd3lNOFdtZXVRbWVxT3NjNnM"

    described_class.configure do |config|
    end
  end

  describe "Auth service" do
    it "generates authorisation_url" do
      service = HykuAddons::Sso::AuthService.new(host: "up.repo")
      expect(service.generate_authorisation_url).to start_with "https://api.workos.com/sso/authorize?client_id"
    end
  end
end
