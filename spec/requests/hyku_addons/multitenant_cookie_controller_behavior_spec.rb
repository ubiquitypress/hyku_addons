# frozen_string_literal: true

require "rails_helper"

RSpec.describe HykuAddons::MultitenantCookieControllerBehavior, type: :request, multitenant: true do
  let(:main_app) { Rails.application.routes.url_helpers }
  let(:user) { create(:user) }
  let(:account) { create(:account, cname: 'foo.bar', frontend_url: 'bar') }
  let(:work) { create(:work, user: user) }
  let(:cookie_details) { cookies.send(:hash_for, nil).fetch('_hyku_session', nil) }

  before do
    login_as(user, scope: :user)
  end

  context "within a tenant" do
    before do
      Site.update(account: account)
      allow(Apartment::Tenant).to receive(:switch).with(account.tenant) do |&block|
        block.call
      end
      host! account.cname
    end

    it "sets the cookie domain to the cname" do
      get main_app.root_path
      expect(cookie_details.domain).to eq account.cname
    end
  end
end
