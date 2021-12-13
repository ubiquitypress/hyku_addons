# frozen_string_literal: true
require "rails_helper"

RSpec.describe Hyku::API::V1::CollectionController, type: :request, clean: true, multitenant: true do
  let(:account) { create(:account) }
  let(:collection_type) { create(:collection_type, brandable: true) }
  let(:collection_type_gid) { collection_type.to_global_id.to_s }
  let(:json_response) { JSON.parse(response.body) }
  let(:cname) { (account.search_only? ? work.to_solr.dig("account_cname_tesim")&.first : account.cname) }
  let(:date_created) { "1992-12-31" }
  let(:description) { "This is a test collection" }

  let(:attributes) do
    {
      # collection_banner_url: collection_banner_url,
      date_created: [date_created],
      collection_type_gid: collection_type_gid,
      description: [description],
      title: ["Test Title"],
      visibility: "open"
    }
  end

  before do
    allow(Apartment::Tenant).to receive(:switch!).with(account.tenant) do |&block|
      block&.call
    end

    Apartment::Tenant.switch!(account.tenant) do
      Site.update(account: account)
    end
  end

  describe "/collection" do
    context 'when repository has content' do
        let(:collection) { Collection.create(attributes) }
        let(:collection_branding) { CollectionBrandingInfo.new(collection_id: collection.id, role: "banner", filename: "nypl-hydra-of-lerna.jpg").save("spec/internal_test_hyku/spec/fixtures/images/nypl-hydra-of-lerna.jpg", false)}
        it "Returns collection json" do
          puts collection_branding.inspect
          get "/api/v1/tenant/#{account.tenant}/collection"
          puts json_response.inspect
          expect(json_response['items']).to include ({"cname"=> cname.to_s,
            "collection_banner_url"=> "http://#{cname}/branding/#{collection.id}/banner/nypl-hydra-of-lerna.jpg",
            "date_created"=>date_created,
            "date_published"=>nil,
            "description"=> "This is a test collection",
            "keywords"=> nil,
            "language"=>nil,
            "license_for_api_tesim"=>nil,
            "publisher"=>nil,
            "related_url"=>nil,
            "resource_type"=>nil,
            "rights_statements_for_api_tesim"=>nil,
            "thumbnail_base64_string"=>nil,
            "thumbnail_url"=>nil,
            "title"=> collection.title.first,
            "total_works"=>nil,
            "type"=>"collection",
            "uuid"=> collection.id.to_s,
            "visibility"=>"open",
            "volumes"=>nil})
        end
      end
    end
  end
