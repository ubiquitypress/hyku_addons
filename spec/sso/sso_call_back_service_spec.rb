# frozen_string_literal: true

RSpec.describe "CallBackService" do
  let(:profile) { instance_double("profile") }
  let(:token) { instance_double("token") }
  let(:profile_and_token) { instance_double("profile_and_token", profile: profile, token: token) }

  before do
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
