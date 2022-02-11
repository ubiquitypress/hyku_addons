# frozen_string_literal: true

RSpec.describe Hyku::RegistrationsController, type: :controller do
  let(:account) { create(:account) }
  let(:site) { Site.new(account: account) }
  let(:account_signup_enabled) { "true" }
  let(:valid_params) do
    {
      user: {
        email: "user@test.com",
        password: "password",
        password_confirmation: "password"
      }
    }
  end

  before do
    allow(Site).to receive(:instance).and_return(site)

    @request.env["devise.mapping"] = Devise.mappings[:user] # rubocop:disable RSpec/InstanceVariable
  end

  describe "#create" do
    before do
      post :create, params: valid_params
    end

    it "redirects to the user to their profile" do
      profile_path = Hyrax::Engine.routes.url_helpers.dashboard_profile_path(User.first, locale: :en)

      expect(response).to redirect_to(profile_path)
      expect(flash[:notice]).to eq "Welcome! You have signed up successfully."
    end
  end
end
