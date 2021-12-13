# frozen_string_literal: true
require "rails_helper"

RSpec.describe Hyku::API::V1::CollectionController, type: :request, clean: true, multitenant: true do
  let(:account) { create(:account) }
  let(:collection) { create(:collection, visibility: "open") }
  let(:collection_branding_instance) do
    instance_double(CollectionBrandingInfo,
                    collection_id: collection.id, role: "banner",
                    local_path: "/fake/path/to/banner.png",
                    alt_text: "This is the banner",
                    target_url: "http://example.com/",
                    height: "", width: "")
  end

  let(:collection_branding_list) { class_double(CollectionBrandingInfo) }

  before do
    allow(Apartment::Tenant).to receive(:switch!).with(account.tenant) do |&block|
      block&.call
    end

    Apartment::Tenant.switch!(account.tenant) do
      Site.update(account: account)
      collection
    end
  end

  context "when repository has content" do
    let(:collection_branding_info) { class_double("CollectionBrandingInfo") }
    let(:json_response) { JSON.parse(response.body) }
    let(:banner_url) { json_response.dig("collection_banner_url") || "" }
    let(:collection_banner_url) { URI.parse(banner_url) }

    before do
      allow(CollectionBrandingInfo).to receive(:where).with(collection_id: collection.id) { collection_branding_list }
      allow(collection_branding_list).to receive(:where).and_return(collection_branding_list)
      allow(collection_branding_list).to receive(:first).and_return(collection_branding_instance)
    end

    it "returns correct collection json" do
      get "/api/v1/tenant/#{account.tenant}/collection/#{collection.id}"
      expect(response.status).to eq(200)
      expect(collection_banner_url.path).to eq(collection_branding_instance.local_path)
    end
  end
end
