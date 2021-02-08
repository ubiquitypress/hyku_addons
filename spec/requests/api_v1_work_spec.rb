# frozen_string_literal: true
require 'rails_helper'

RSpec.describe Hyku::API::V1::WorkController, type: :request, clean: true, multitenant: true do
  let(:account) { create(:account) }
  let(:user) { create(:user) }
  let(:work) { nil }

  before do
    WebMock.disable!
    Apartment::Tenant.create(account.tenant)
    Apartment::Tenant.switch(account.tenant) do
      Site.update(account: account)
      user
      work
    end
  end

  after do
    WebMock.enable!
    Apartment::Tenant.drop(account.tenant)
  end

  describe "/work/:id" do
    let(:json_response) { JSON.parse(response.body) }

    context 'when repository has content' do
      let(:work) { create(:work, visibility: 'open') }

      it 'returns work json' do
        get "/api/v1/tenant/#{account.tenant}/work/#{work.id}"
        expect(response.status).to eq(200)
        expect(json_response).to include("abstract" => nil,
                                         "additional_info" => nil,
                                         "additional_links" => nil,
                                         "admin_set_name" => "",
                                         #  "alternative_journal_title" => nil,
                                         "alternative_title" => nil,
                                         #  "article_number" => nil,
                                         #  "book_title" => nil,
                                         "buy_book" => nil,
                                         #  "challenged" => nil,
                                         "cname" => account.cname,
                                         #  "collections" => nil,
                                         #  "current_he_institution" => nil,
                                         #  "date_accepted" => nil,
                                         "date_published" => nil,
                                         "date_submitted" => nil,
                                         #  "degree" => nil,
                                         #  "dewey" => nil,
                                         #  "display" => "full",
                                         #  "doi" => nil,
                                         #  "download_link" => nil,
                                         #  "duration" => nil,
                                         #  "edition" => nil,
                                         #  "eissn" => nil,
                                         #  "event_date" => nil,
                                         #  "event_location" => nil,
                                         #  "event_title" => nil,
                                         #  "files" => nil,
                                         #  "funder" => nil,
                                         #  "funder_project_reference" => nil,
                                         #  "institution" => nil,
                                         "irb_number" => nil,
                                         "irb_status" => nil,
                                         "is_included_in" => nil,
                                         "isbn" => nil,
                                         "issn" => nil,
                                         "issue" => nil,
                                         "journal_title" => nil,
                                         "keywords" => [],
                                         "language" => [],
                                         #  "library_of_congress_classification" => nil,
                                         "license" => [],
                                         #  "location" => nil,
                                         #  "material_media" => nil,
                                         #  "migration_id" => nil,
                                         #  "official_url" => nil,
                                         "organisational_unit" => nil,
                                         #  "outcome" => nil,
                                         "page_display_order_number" => nil,
                                         "pagination" => nil,
                                         #  "participant" => nil,
                                         #  "photo_caption" => nil,
                                         #  "photo_description" => nil,
                                         #  "place_of_publication" => nil,
                                         #  "project_name" => nil,
                                         "publisher" => [],
                                         #  "qualification_level" => nil,
                                         #  "qualification_name" => nil,
                                         #  "reading_level" => nil,
                                         "refereed" => nil,
                                         #  "related_exhibition" => nil,
                                         #  "related_exhibition_date" => nil,
                                         #  "related_exhibition_venue" => nil,
                                         "related_url" => [],
                                         "resource_type" => [],
                                         #  "review_data" => nil,
                                         "rights_holder" => nil,
                                         "rights_statement" => [],
                                         #  "series_name" => nil,
                                         "source" => [],
                                         "subject" => [],
                                         #  "thumbnail_base64_string" => nil,
                                         "thumbnail_url" => nil,
                                         "title" => "Test title",
                                         "type" => "work",
                                         "uuid" => work.id,
                                         #  "version" => nil,
                                         "visibility" => work.visibility,
                                         "volume" => nil,
                                         "work_type" => "GenericWork",
                                         "workflow_status" => nil)
      end

      it 'returns work json with data when it exists' do
        abstract = "Lorem ipsum dolor sit amet, consectetur adipiscing elit. Morbi at tincidunt nisl. Nulla et lacus consequat, interdum eros nec, pulvinar."
        work.abstract = abstract
        work.save
        get "/api/v1/tenant/#{account.tenant}/work/#{work.id}"
        expect(json_response).to include("abstract" => [abstract])
      end
    end
  end
end
