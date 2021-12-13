# frozen_string_literal: true
require "rails_helper"

RSpec.describe Hyku::API::V1::CollectionController, type: :request, clean: true, multitenant: true do
  let(:account) { create(:account) }
  let(:cname) { (account.search_only? ? work.to_solr.dig("account_cname_tesim")&.first : account.cname) }
  let(:collection) { create(:collection, date_created: ["1992-12-31"], description: ["This is a test collection"], title: ["Test Title"], visibility: "open") }
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

    before do
      allow(CollectionBrandingInfo).to receive(:where).with(collection_id: collection.id) { collection_branding_list }
      allow(collection_branding_list).to receive(:where).and_return(collection_branding_list)
      allow(collection_branding_list).to receive(:first).and_return(collection_branding_instance)
    end

    # rubocop:disable  RSpec/ExampleLength
    it "returns correct collection json" do
      get "/api/v1/tenant/#{account.tenant}/collection/#{collection.id}"
      expect(response.status).to eq(200)
      expect(json_response).to include("cname" => cname.to_s,
                                       "collection_banner_url" => "http://#{cname}/fake/path/to/banner.png",
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
                                       "works" => [])
      # rubocop:enable  RSpec/ExampleLength
    end
  end
end
