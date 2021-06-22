# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyku::API::V1::TenantController, type: :request, clean: true, multitenant: true do
  let(:account) { create(:account, name: 'test') }
  let(:json_response) { JSON.parse(response.body) }
  let(:work_types) { ["Article", "Book", "ThesisOrDissertation", "BookChapter"] }

  before do
    allow(Apartment::Tenant).to receive(:switch!).with(account.tenant) do |&block|
      block&.call
    end

    Apartment::Tenant.switch!(account.tenant) { Site.update(account: account) }
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
  end
end
