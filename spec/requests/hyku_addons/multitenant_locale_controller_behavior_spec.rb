# frozen_string_literal: true

require "rails_helper"

RSpec.describe HykuAddons::MultitenantLocaleControllerBehavior, type: :request, multitenant: true do
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

  describe "" do
    it "" do
      # byebug
      get main_app.polymorphic_path(work)
      # byebug
    end
  end
end
