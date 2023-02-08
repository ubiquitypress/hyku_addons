# frozen_string_literal: true

require "rails_helper"
# TODO: flaky tests. Need fixing.
RSpec.xdescribe HykuAddons::MultitenantLocaleControllerBehavior, type: :request, multitenant: true do
  let(:main_app) { Rails.application.routes.url_helpers }
  let(:user) { create(:user) }
  let(:account) { create(:account) }
  let(:work) { create(:work, user: user) }

  before do
    login_as(user, scope: :user)

    Site.update(account: account)
    allow(Apartment::Tenant).to receive(:switch).with(account.tenant) do |&block|
      block.call
    end
    host! account.cname
  end

  describe "when no locale name is set on an account" do
    before do
      account.settings["locale_name"] = nil
      account.save

      get main_app.polymorphic_path(work)
    end

    it "returns a normal locale code" do
      expect(response.body).to include('lang="en"')
    end
  end

  describe "when a locale name is set on an account" do
    before do
      account.settings["locale_name"] = "test"
      account.save

      get main_app.polymorphic_path(work)
    end

    it "appends the locale name to the languge code" do
      expect(response.body).to include('lang="en-TEST"')
    end
  end
end
