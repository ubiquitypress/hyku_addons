# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyku::API::V1::WorkController, type: :request, clean: true, multitenant: true do
  let(:account) { create(:account) }
  let(:work) { nil }

  before do
    allow(Apartment::Tenant).to receive(:switch!).with(account.tenant) do |&block|
      block&.call
    end

    Apartment::Tenant.switch!(account.tenant) do
      Site.update(account: account)
      work
    end
  end

  describe "/work/:id" do
    let(:json_response) { JSON.parse(response.body) }

    context 'when repository has content' do
      let(:work) { create(:work, visibility: 'open') }

      it 'returns work json' do
        get "/api/v1/tenant/#{account.tenant}/work/#{work.id}"
        expect(response.status).to eq(200)
        expect(json_response).to include("abstract" => nil,
                                         "additional_info" => [],
                                         "additional_links" => nil,
                                         "admin_set_name" => "",
                                         #  "alternative_journal_title" => nil,
                                         "alternative_title" => [],
                                         #  "article_number" => nil,
                                         #  "book_title" => nil,
                                         "buy_book" => nil,
                                         "challenged" => nil,
                                         "cname" => account.cname,
                                         #  "collections" => nil,
                                         #  "current_he_institution" => nil,
                                         #  "date_accepted" => nil,
                                         "date_published" => [],
                                         "date_submitted" => nil,
                                         "degree" => nil,
                                         #  "dewey" => nil,
                                         #  "display" => "full",
                                         #  "doi" => nil,
                                         #  "download_link" => nil,
                                         "duration" => [],
                                         #  "edition" => nil,
                                         #  "eissn" => nil,
                                         #  "event_date" => nil,
                                         #  "event_location" => nil,
                                         #  "event_title" => nil,
                                         "files" => {
                                           "has_private_files" => false,
                                           "has_registered_files" => false,
                                           "has_public_files" => false
                                         },
                                         #  "funder" => nil,
                                         #  "funder_project_reference" => nil,
                                         #  "institution" => nil,
                                         "irb_number" => nil,
                                         "irb_status" => nil,
                                         "is_included_in" => nil,
                                         "isbn" => [],
                                         "issn" => [],
                                         "issue" => [],
                                         "journal_title" => [],
                                         "keywords" => [],
                                         # "language" => [], # Only present if has values
                                         #  "library_of_congress_classification" => nil,
                                         "license" => [],
                                         "location" => nil,
                                         #  "material_media" => nil,
                                         #  "migration_id" => nil,
                                         #  "official_url" => nil,
                                         "org_unit" => [],
                                         "outcome" => nil,
                                         "page_display_order_number" => nil,
                                         "pagination" => [],
                                         "participant" => nil,
                                         "photo_caption" => nil,
                                         "photo_description" => nil,
                                         #  "place_of_publication" => nil,
                                         #  "project_name" => nil,
                                         "publisher" => [],
                                         #  "qualification_level" => nil,
                                         #  "qualification_name" => nil,
                                         "reading_level" => nil,
                                         "refereed" => [],
                                         #  "related_exhibition" => nil,
                                         #  "related_exhibition_date" => nil,
                                         #  "related_exhibition_venue" => nil,
                                         "related_url" => [],
                                         "resource_type" => [],
                                         #  "review_data" => nil,
                                         "rights_holder" => [],
                                         "rights_statement" => [],
                                         #  "series_name" => nil,
                                         "source" => [],
                                         "subject" => [],
                                         #  "thumbnail_base64_string" => nil,
                                         "thumbnail_url" => nil,
                                         "title" => "Test title",
                                         "type" => "work",
                                         "uuid" => work.id,
                                         "version" => [],
                                         "visibility" => work.visibility,
                                         "volume" => [],
                                         "work_type" => "GenericWork",
                                         "workflow_status" => nil)
      end

      context 'with data when it exists' do
        let(:work) { create(:work, visibility: 'open', abstract: abstract, creator: creator) }
        let(:abstract) { 'Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi at tincidunt nisl. Nulla et lacus consequat, interdum eros nec, pulvinar.' }
        let(:creator) { ["[{\"creator_organization_name\":\"\",\"creator_given_name\":\"Bertie\",\"creator_family_name\":\"Wooles\",\"creator_name_type\":\"Personal\",\"creator_orcid\":\"0000 1111 2222 3333\",\"creator_isni\":\"\",\"creator_ror\":\"\",\"creator_grid\":\"\",\"creator_wikidata\":\"\"}]"] }
        it 'returns work json' do
          get "/api/v1/tenant/#{account.tenant}/work/#{work.id}"
          expect(json_response).to include("abstract" => abstract,
                                           "creator" => [{ "creator_organization_name" => "", "creator_given_name" => "Bertie", "creator_family_name" => "Wooles", "creator_name_type" => "Personal", "creator_orcid" => "0000 1111 2222 3333", "creator_isni" => "", "creator_ror" => "", "creator_grid" => "", "creator_wikidata" => "" }])
        end
      end
    end
  end
end
