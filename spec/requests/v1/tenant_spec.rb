# frozen_string_literal: true

require "rails_helper"

RSpec.describe Hyku::API::V1::TenantController, type: :request, clean: true, multitenant: true do
  let(:account) { create(:account, name: "test") }
  let(:json_response) { JSON.parse(response.body) }
  let(:work_types) { ["Article", "Book", "ThesisOrDissertation", "BookChapter"] }

  before do
    allow(Apartment::Tenant).to receive(:switch!).with(account.tenant) do |&block|
      block&.call
    end

    Apartment::Tenant.switch!(account.tenant) { Site.update(account: account) }

    # Ensure that if caching has been enabled elsewhere by the test suite it is disabled for this test
    account.setup_tenant_cache(false)
  end

  describe "/tenant/:id" do
    it "includes the default tenant setting" do
      get "/api/v1/tenant/#{account.tenant}"

      expect(response.status).to eq(200)
      expect(json_response.keys).to include("settings")
      expect(json_response.dig("settings", "google_scholarly_work_types")).to eq(work_types)
    end

    it "includes the updated tenant setting" do
      account.settings["google_scholarly_work_types"] = ["Book"]
      account.save

      get "/api/v1/tenant/#{account.tenant}"

      expect(response.status).to eq(200)
      expect(json_response.dig("settings", "google_scholarly_work_types")).to eq(["Book"])
    end

    context "annotations for pdf_viewer" do
      let(:parsed_response) { JSON.parse(response.body)&.fetch("annotation") }

      it "includes annotation status" do
        get "/api/v1/tenant/#{account.tenant}"
        expect(parsed_response).to be_falsey
      end

      it "can return true when annotation is on" do
        allow(Flipflop).to receive(:enabled?).with(:annotation).and_return(true)
        get "/api/v1/tenant/#{account.tenant}"
        expect(parsed_response).to be_truthy
      end
    end

    context "with private settings do" do
      before do
        Account.private_settings.each do |setting|
          account.settings[setting] = { foo: "bar" }
        end
        account.save
      end

      it "excludes private settings" do
        get "/api/v1/tenant/#{account.tenant}"
        expect(json_response.keys).not_to include(Account.private_settings)
      end
    end
  end
end
