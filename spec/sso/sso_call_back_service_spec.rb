# frozen_string_literal: true

RSpec.describe "CallBackService" do
  let(:profile) { instance_double("profile") }
  let(:token) { instance_double("token") }
  let(:profile_and_token) { instance_double("profile_and_token", profile: profile, token: token) }

  before do
    ENV["ORGANISATION_ID"] = "org_01GP3QSZ0967S8HZ9KYWT63Y1Y"
    ENV["WORKOS_CLIENT_ID"] = "client_01GG7DRH9KVK3QNX2S6RGWA3CQ"
    ENV["WORKOS_API_KEY"] = "sk_test_a2V5XzAxR0c3RFJIOURYM0NSNUdCTjU2Q0VCTkVDLFcxUHliQWkzd3lNOFdtZXVRbWVxT3NjNnM"
    HykuAddons::Sso.configure do |config|
    end
    allow(WorkOS::SSO).to receive(:profile_and_token).and_return(profile_and_token)
  end

  it "handlers call back" do
    logged_on = false
    service = HykuAddons::Sso::CallBackService.new(params: { code: 1234 })
    service.handle { |_profile, _password| logged_on = true }
    expect(logged_on).to eq(true)
  end
end
