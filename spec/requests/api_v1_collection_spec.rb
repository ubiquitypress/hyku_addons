# frozen_string_literal: true
require "rails_helper"
# TODO: flaky tests. Need fixing.
RSpec.xdescribe Hyku::API::V1::CollectionController, type: :request, clean: true, multitenant: true do
  let(:account) { create(:account) }
  let(:cname) { (account.search_only? ? work.to_solr.dig("account_cname_tesim")&.first : account.cname) }
  let(:collection) { create(:collection, date_created: ["1992-12-31"], description: ["This is a test collection"], title: ["Test Title"], visibility: "open") }

  let(:banner) do
    instance_double(CollectionBrandingInfo,
                    collection_id: collection.id, role: "banner",
                    local_path: "/fake/path/to/banner.png",
                    alt_text: "This is the banner",
                    target_url: "http://example.com/",
                    height: "", width: "")
  end

  let(:logo) do
    instance_double(CollectionBrandingInfo,
                    collection_id: collection.id, role: "logo",
                    local_path: "/fake/path/to/logo.png",
                    alt_text: "This is the logo",
                    target_url: "http://example.com/",
                    height: "", width: "")
  end

  let(:logo_2) do
    instance_double(CollectionBrandingInfo,
                    collection_id: collection.id, role: "logo",
                    local_path: "/fake/path/to/logo2.png",
                    alt_text: "second logo",
                    target_url: "http://example-images.com/",
                    height: "", width: "")
  end

  let(:api_multiple_collection_logo) do
    [{ "target_url" => "http://example.com/", "alt_text" => "This is the logo", "url" => "http://#{cname}/fake/path/to/logo.png", "positions" => 0 },
     { "target_url" => "http://example-images.com/", "alt_text" => "second logo", "url" => "http://#{cname}/fake/path/to/logo2.png", "positions" => 1 }]
  end

  let(:api_multiple_collection_banner) do
    [{ "target_url" => "http://example.com/", "alt_text" => "This is the banner", "url" => "http://#{cname}/fake/path/to/banner.png", "positions" => 0 }]
  end

  let(:json_response) { JSON.parse(response.body) }

  let(:results) do
    { "cname" => cname.to_s,
      "collection_banner_url" => "http://#{cname}/fake/path/to/banner.png",
      "collection_logo_url" => "http://#{cname}/fake/path/to/logo.png",
      "collection_logo_alt_text" => "This is the logo",
      "collection_logo_target_url" => "http://example.com/",
      "collection_logo" => api_multiple_collection_logo,
      "collection_banner" => api_multiple_collection_banner,
      "date_created" => "1992-12-31",
      "date_published" => nil,
      "description" => "This is a test collection",
      "keywords" => nil,
      "language" => nil,
      "license_for_api_tesim" => nil,
      "publisher" => nil,
      "related_url" => nil,
      "resource_type" => nil,
      "rights_statements_for_api_tesim" => nil,
      "thumbnail_base64_string" => nil,
      "thumbnail_url" => nil,
      "title" => collection.title.first,
      "total_works" => 0,
      "type" => "collection",
      "uuid" => collection.id.to_s,
      "visibility" => "open",
      "volumes" => nil,
      "works" => [] }
  end

  before do
    allow(Apartment::Tenant).to receive(:switch!).with(account.tenant) do |&block|
      block&.call
    end

    Apartment::Tenant.switch!(account.tenant) do
      Site.update(account: account)
      collection
    end

    # Ensure that if caching has been enabled elsewhere by the test suite it is disabled for this test
    account.setup_tenant_cache(false)
  end

  context "when repository has content" do
    before do
      collection_branding_list = class_double(CollectionBrandingInfo)
      collection_logo_list = class_double(CollectionBrandingInfo)
      allow(CollectionBrandingInfo).to receive(:where).with(collection_id: collection.id, role: "banner") { [banner] }
      allow(CollectionBrandingInfo).to receive(:where).with(collection_id: collection.id, role: "logo") { [logo, logo_2] }
      allow(collection_branding_list).to receive(:first).and_return(banner)
      allow(collection_logo_list).to receive(:first).and_return(logo)
    end

    context "fetching banner and logo" do
      it "returns correct collection json" do
        get "/api/v1/tenant/#{account.tenant}/collection/#{collection.id}"
        expect(response.status).to eq(200)
        expect(json_response).to include(results)
      end
    end
  end
end
