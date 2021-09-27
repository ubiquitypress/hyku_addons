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
                                         "adapted_from" => nil,
                                         "additional_info" => nil,
                                         "additional_links" => nil,
                                         "admin_set_name" => "",
                                         "advisor" => nil,
                                         "alternative_book_title" => nil,
                                         "alternative_journal_title" => nil,
                                         "alternative_title" => nil,
                                         "audience" => nil,
                                         "book_title" => nil,
                                         "buy_book" => nil,
                                         "challenged" => nil,
                                         "citation" => nil,
                                         "cname" => account.cname,
                                         "collections" => [],
                                         "committee_member" => nil,
                                         "contributor" => [],
                                         "creator" => [],
                                         "date_accepted" => nil,
                                         "date_published" => nil,
                                         "date_published_text" => nil,
                                         "date_submitted" => nil,
                                         "degree" => nil,
                                         "dewey" => nil,
                                         "doi" => nil,
                                         "duration" => nil,
                                         "edition" => nil,
                                         "eissn" => nil,
                                         "event_date" => nil,
                                         "event_location" => nil,
                                         "event_title" => nil,
                                         "extent" => nil,
                                         "files" => {
                                           "has_private_files" => false,
                                           "has_registered_files" => false,
                                           "has_public_files" => false
                                         },
                                         "funder" => nil,
                                         "funding_description" => nil,
                                         "georeferenced" => nil,
                                         "institution" => nil,
                                         "irb_number" => nil,
                                         "irb_status" => nil,
                                         "is_format_of" => nil,
                                         "is_included_in" => nil,
                                         "isbn" => nil,
                                         "issn" => nil,
                                         "issue" => nil,
                                         "journal_frequency" => nil,
                                         "journal_title" => nil,
                                         "keywords" => [],
                                         "latitude" => nil,
                                         "library_of_congress_classification" => nil,
                                         # "language" => [], # Only present if has values
                                         "license" => [],
                                         "location" => nil,
                                         "longitude" => nil,
                                         "medium" => nil,
                                         "mesh" => nil,
                                         "official_link" => nil,
                                         "official_url" => nil,
                                         "org_unit" => nil,
                                         "outcome" => nil,
                                         "page_display_order_number" => nil,
                                         "pagination" => nil,
                                         "part_of" => nil,
                                         "participant" => nil,
                                         "photo_caption" => nil,
                                         "photo_description" => nil,
                                         "place_of_publication" => nil,
                                         "prerequisites" => nil,
                                         #  "project_name" => nil,
                                         "publisher" => [],
                                         "qualification_grantor" => nil,
                                         "qualification_level" => nil,
                                         "qualification_subject_text" => nil,
                                         "reading_level" => nil,
                                         "refereed" => nil,
                                         "references" => nil,
                                         "related_exhibition" => nil,
                                         "related_exhibition_date" => nil,
                                         "related_exhibition_venue" => nil,
                                         "related_material" => nil,
                                         "related_url" => [],
                                         "resource_type" => [],
                                         #  "review_data" => nil,
                                         "rights_holder" => nil,
                                         "rights_statement" => [],
                                         "rights_statement_text" => nil,
                                         "series_name" => nil,
                                         "source" => [],
                                         "subject" => nil,
                                         "subject_text" => nil,
                                         "suggested_reviewers" => nil,
                                         "suggested_student_reviewers" => nil,
                                         "table_of_contents" => nil,
                                         #  "thumbnail_base64_string" => nil,
                                         "thumbnail_url" => nil,
                                         "time" => nil,
                                         "title" => "Test title",
                                         "type" => "work",
                                         "uuid" => work.id,
                                         "version" => nil,
                                         "visibility" => work.visibility,
                                         "volume" => nil,
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
