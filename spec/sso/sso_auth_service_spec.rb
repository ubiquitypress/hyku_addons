# frozen_string_literal: true

RSpec.describe HykuAddons::Sso do
  before do
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
