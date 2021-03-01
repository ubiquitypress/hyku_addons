# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyku::API::V1::TenantController, type: :request, clean: true, multitenant: true do
  let(:account) { create(:account, name: 'test') }
  let(:json_response) { JSON.parse(response.body) }

  before do
    WebMock.disable!
    Apartment::Tenant.create(account.tenant)
    Apartment::Tenant.switch(account.tenant) { Site.update(account: account) }
  end

  after do
    WebMock.enable!
    Apartment::Tenant.drop(account.tenant)
  end

  describe "/tenant/:id" do
    let(:work_types) { ["Article", "Book", "ThesisOrDissertation", "BookChapter"] }

    it "includes the tenant setting" do
      get "/api/v1/tenant/#{account.tenant}"

      expect(response.status).to eq(200)
      expect(json_response.keys).to include("settings")
      expect(json_response.dig("settings", "google_scholarly_work_types")).to eq(work_types)
    end
  end
end
