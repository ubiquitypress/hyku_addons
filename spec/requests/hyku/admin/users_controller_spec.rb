# frozen_string_literal: true
require "rails_helper"

RSpec.describe Admin::UsersController, type: :controller do
  context "as an admin user" do
    let(:account) { create(:account) }
    let(:user) { create(:user, email: "abc@test.com", invitation_accepted_at: DateTime.now.utc) }
    let(:admin_user) { create(:user, email: "admin@test.com", invitation_accepted_at: DateTime.now.utc) }
    let(:main_app) { Rails.application.routes.url_helpers }

    before do
      allow(Apartment::Tenant).to receive(:switch!).with(account.tenant) do |&block|
        block&.call
      end

      Apartment::Tenant.switch!(account.tenant) do
        Site.update(account: account)
        user
        admin_user.add_role("admin", Site.instance)
        sign_in admin_user
      end
    end

    describe "DELETE #destroy" do
      before do
        delete :destroy, params: { id: user.email }
      end

      it "can delete via /admin/users/" do
        expect(response).to redirect_to("/admin/users?locale=en")
      end

      it "flashes a success message" do
        expect(response.request.flash[:notice]).not_to be_nil
        expect(response.request.flash[:notice]).to match(/User "#{user.email}" has been successfully deleted./)
      end
    end
  end
end
