# frozen_string_literal: true
require "rails_helper"

RSpec.describe Admin::UsersController, type: :controller do
  context "as an admin user" do
    let(:account) { create(:account) }
    let(:user) { create(:user, email: "abc@test.com", invitation_accepted_at: DateTime.now.utc) }
    let(:user_with_work) { create(:user, email: "bbb@test.com", invitation_accepted_at: DateTime.now.utc) }
    let(:user_with_work_file) { create(:user, email: "ddd@test.com", invitation_accepted_at: DateTime.now.utc) }
    let(:admin_user) { create(:user, email: "admin@test.com", invitation_accepted_at: DateTime.now.utc) }
    let(:work_with_file) { create(:work_with_one_file, visibility: "open", user: user_with_work_file) }
    let(:work) { create(:work, visibility: "open", user: user_with_work) }
    let(:main_app) { Rails.application.routes.url_helpers }

    before do
      allow(Apartment::Tenant).to receive(:switch!).with(account.tenant) do |&block|
        block&.call
      end

      Apartment::Tenant.switch!(account.tenant) do
        Site.update(account: account)
        user.add_role("registered", Site.instance)
        user_with_work.add_role("registered", Site.instance)
        user_with_work_file.add_role("registered", Site.instance)
        admin_user.add_role("admin", Site.instance)
        work
        work_with_file
        sign_in admin_user
      end
    end

    describe "DELETE #destroy" do
      context "User with no works" do
        before do
          delete :destroy, params: { id: user.email }
        end

        it "can delete via /admin/users/ for users with no work" do
          expect(response).to redirect_to("/admin/users?locale=en")
        end

        it "flashes a success message" do
          expect(response.request.flash[:notice]).not_to be_nil
          expect(response.request.flash[:notice]).to match(/User "#{user.email}" has been successfully deleted./)
        end
      end

      context "Soft deletes User with a work" do
        before do
          delete :destroy, params: { id: user_with_work.email }
        end

        it "can delete via /admin/users/ soft deletes users with works" do
          expect(response).to redirect_to("/admin/users?locale=en")
        end

        it "flashes a success message" do
          expect(response.request.flash[:notice]).to match(/User "#{user_with_work.email}" has been successfully deleted./)
        end

        it "soft deleted user can not sign_in" do
          expect(user_with_work.reload.active_for_authentication?).to be_falsey
        end
      end

      context "Soft with deletes User with work and file" do
        before do
          delete :destroy, params: { id: user_with_work_file.email }
        end

        it "can delete via /admin/users/  soft deletes user" do
          expect(response).to redirect_to("/admin/users?locale=en")
        end

        it "flashes a success message" do
          expect(response.request.flash[:notice]).to match(/User "#{user_with_work_file.email}" has been successfully deleted./)
        end

        it "soft deleted user should not be active for devise authentication" do
          expect(user_with_work_file.reload.active_for_authentication?).to be_falsey
        end
      end
    end
  end
end
