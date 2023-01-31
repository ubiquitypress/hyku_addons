# frozen_string_literal: true
require "rails_helper"

RSpec.describe HykuAddons::SessionsController, type: :controller do
  let(:client_id) { "client_id" }
  let(:org_uid) { "org_uid" }
  let(:profile) { WorkOS::SSO::Profile.new(email: "test@example.com") }
  let(:authorization_url) { "authorization_url" }
  let(:profile_and_token) { WorkOS::SSO::ProfileAndToken.new(profile: profile) }
  let(:user) { create(:user, email: "test@example.com") }

  describe "#auth" do
    it "redirects to the authorization URL" do
      ENV["WORKOS_CLIENT_ID"] = client_id
      ENV["ORGANIZATION_UID"] = org_uid

      allow(WorkOS::SSO).to receive(:authorization_url).and_return(authorization_url)

      get :auth

      expect(response).to redirect_to(authorization_url)
    end
  end

  describe "#callback" do
    before do
      ENV["WORKOS_CLIENT_ID"] = client_id
      allow(WorkOS::SSO).to receive(:profile_and_token).and_return(profile_and_token)
    end

    it "signs in the user" do
      get :callback, params: { code: "code" }

      expect(controller.current_user).to eq(user)
      expect(response).to redirect_to("/dashboard")
    end
  end
end
