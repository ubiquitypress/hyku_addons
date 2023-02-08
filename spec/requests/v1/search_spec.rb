# frozen_string_literal: true
require "rails_helper"
# TODO: flaky tests. Need fixing.
RSpec.xdescribe Hyku::API::V1::SearchController, type: :request, clean: true, multitenant: true do
  let(:account) { create(:account) }
  let(:user) { create(:user) }
  let(:collection) { nil }
  let(:work) { create(:work, title: ["work"], visibility: "open", date_published: "1996-02") }
  let(:work2) { create(:work, title: ["work 2"], visibility: "open", date_published: "2016") }
  let(:work3) { create(:work, title: ["work 3"], visibility: "open", date_published: "2015-10-12") }
  let(:work4) { create(:work, title: ["work 4"], visibility: "open", date_published: "1990-01-11") }
  let(:work5) { create(:work, title: ["work 5"], visibility: "open", date_published: "2015") }

  before do
    allow(Apartment::Tenant).to receive(:switch!).with(account.tenant) do |&block|
      block&.call
    end

    Apartment::Tenant.switch!(account.tenant) do
      Site.update(account: account)
      user
      work
      work2
      work3
      work4
      work5
      collection
    end

    # Ensure that if caching has been enabled elsewhere by the test suite it is disabled for this test
    account.setup_tenant_cache(false)
  end

  describe "API search" do
    let(:json_response) { JSON.parse(response.body) }

    context "sort by date_published" do
      let(:sort) { "date_published_ssi asc" }
      let(:sort_desc) { "date_published_ssi desc" }

      it "can sort results by date_published asc" do
        get "/api/v1/tenant/#{account.tenant}/search?sort=#{sort}"
        expect(response.status).to eq(200)
        expect(json_response["total"]).to eq 5
        expect(json_response["items"][0]["uuid"]).to eq work4.id
        expect(json_response["items"][1]["uuid"]).to eq work.id
        expect(json_response["items"][4]["uuid"]).to eq work2.id
        expect(json_response["facet_counts"]).to be_present
      end

      it "can sort results by date_published descending" do
        get "/api/v1/tenant/#{account.tenant}/search?sort=#{sort_desc}"
        expect(json_response["items"][0]["title"]).to eq work2.title.first
        expect(json_response["items"][1]["title"]).to eq work3.title.first
        expect(json_response["items"][4]["title"]).to eq work4.title.first
      end
    end
  end
end
