# frozen_string_literal: true
require "rails_helper"

RSpec.describe Hyku::API::V1::WorkController, type: :request, clean: true, multitenant: true do
  let(:account) { create(:account) }
  let(:work) { nil }
  let(:abstract) { "Swedish comic about the adventures of the residents of Moominvalley." }
  let(:add_info) { "Nothing to report" }
  let(:alt_title1) { "alt-title" }
  let(:book_title) { "Book Title 1" }
  let(:created_year) { "1945" }
  let(:creator1_first_name) { "Sebastian" }
  let(:creator1_last_name) { "Hageneuer" }
  let(:creator1_orcid) { "0000-0003-0652-4625" }
  let(:creator1) do
    {
      creator_name_type: "Personal",
      creator_given_name: creator1_first_name,
      creator_family_name: creator1_last_name,
      creator_orcid: "https://sandbox.orcid.org/#{creator1_orcid}"
    }
  end
  let(:creator2_first_name) { "Johnny" }
  let(:creator2_last_name) { "Testing" }
  let(:creator2) do
    {
      creator_name_type: "Personal",
      creator_given_name: creator2_first_name,
      creator_family_name: creator2_last_name
    }
  end
  let(:contributor1_first_name) { "Jannet" }
  let(:contributor1_last_name) { "Gnitset" }
  let(:contributor1_orcid) { "0000-1234-5109-3702" }
  let(:contributor1_role) { "Other" }
  let(:contributor1) do
    {
      contributor_name_type: "Personal",
      contributor_given_name: contributor1_first_name,
      contributor_family_name: contributor1_last_name,
      contributor_orcid: "https://orcid.org/#{contributor1_orcid}"
    }
  end
  let(:date_accepted) { "2018-01-02" }
  let(:date_created) { "#{created_year}-01-01" }
  let(:date_published) { "#{published_year}-03-12" }
  let(:date_submitted) { "2019-01-02" }
  let(:doi) { "10.18130/v3-k4an-w022" }
  let(:duration1) { "duration1" }
  let(:edition) { "1" }
  let(:editor1_first_name) { "Joan" }
  let(:editor1_last_name) { "Smile" }
  let(:editor1_orcid) { "4567-1234-0987-1234" }
  let(:editor1_role) { "Other" }
  let(:editor1) do
    {
      editor_name_type: "Personal",
      editor_given_name: editor1_first_name,
      editor_family_name: editor1_last_name,
      editor_orcid: "https://orcid.org/#{editor1_orcid}"
    }
  end
  let(:eissn) { "1234-5678" }
  let(:fndr_project_ref) { "test" }
  let(:institution1) { "British Library" }
  let(:isbn) { "9781770460621" }
  let(:issn) { "0987654321" }
  let(:issue) { "6" }
  let(:issue) { 7 }
  let(:journal_title) { "Test Journal Title" }
  let(:keyword) { "Lighthouses" }
  let(:language) { "Swedish" }
  let(:language2) { "English" }
  let(:official_link) { "http://test-url.com" }
  let(:org_unit1) { "Department of Crackers" }
  let(:pagination) { "1-2" }
  let(:place_of_publication1) { "Finland" }
  let(:project_name1) { "Project name 1" }
  let(:published_year) { "1946" }
  let(:publisher) { "Schildts" }
  let(:resource_type) { "Book" }
  let(:series_name) { "Series name" }
  let(:title) { "Moomin" }
  let(:version_number) { "3" }
  let(:volume) { 2 }

  let(:attributes) do
    {
      abstract: abstract,
      add_info: add_info,
      alt_title: [alt_title1],
      book_title: book_title,
      contributor: [[contributor1].to_json],
      creator: [[creator1, creator2].to_json],
      date_accepted: date_accepted,
      date_published: date_published,
      date_submitted: date_submitted,
      doi: [doi],
      duration: [duration1],
      edition: edition,
      editor: [[editor1].to_json],
      eissn: eissn,
      fndr_project_ref: [fndr_project_ref],
      institution: [institution1],
      isbn: isbn,
      issn: issn,
      issue: issue,
      journal_title: journal_title,
      keyword: [keyword],
      language: [language],
      official_link: official_link,
      org_unit: [org_unit1],
      pagination: pagination,
      place_of_publication: [place_of_publication1],
      project_name: [project_name1],
      publisher: [publisher],
      resource_type: [resource_type],
      series_name: [series_name],
      source: [""],
      title: [title],
      version_number: [version_number],
      visibility: "open",
      volume: [volume]
    }
  end

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
    let(:cname) { (account.search_only? ? work.to_solr.dig("account_cname_tesim")&.first : account.cname) }
    context "when repository has content" do
      let(:work) { create(:work, visibility: "open") }

      it "returns work json" do
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
                                         "article_number" => nil,
                                         "audience" => nil,
                                         "book_title" => nil,
                                         "buy_book" => nil,
                                         "challenged" => nil,
                                         "citation" => nil,
                                         "cname" => cname,
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
                                         "funder_project_ref" => nil,
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
                                         "project_name" => nil,
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
                                         "related_url" => nil,
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

      context "with data when it exists" do
        let(:work) { GenericWork.new(attributes) }
        it "returns work json" do
          work.save!
          get "/api/v1/tenant/#{account.tenant}/work/#{work.id}"

          expect(json_response["cname"]).to be_a(String)
          expect(json_response).to include("abstract" => "Swedish comic about the adventures of the residents of Moominvalley.",
                                           "adapted_from" => nil,
                                           "additional_info" => ["Nothing to report"],
                                           "additional_links" => nil,
                                           "admin_set_name" => "",
                                           "advisor" => nil,
                                           "alternative_book_title" => nil,
                                           "alternative_journal_title" => nil,
                                           "alternative_title" => ["alt-title"],
                                           "article_number" => nil,
                                           "audience" => nil,
                                           "book_title" => ["Book Title 1"],
                                           "buy_book" => nil,
                                           "challenged" => nil,
                                           "citation" => nil,
                                           "cname" => cname,
                                           "collections" => [],
                                           "committee_member" => nil,
                                           "contributor" => [{ "contributor_family_name" => "Gnitset",
                                                               "contributor_given_name" => "Jannet",
                                                               "contributor_name_type" => "Personal",
                                                               "contributor_orcid" => "https://orcid.org/0000-1234-5109-3702" }],

                                           "creator" => [{ "creator_family_name" => "Hageneuer",
                                                           "creator_given_name" => "Sebastian",
                                                           "creator_name_type" => "Personal",
                                                           "creator_orcid" => "https://sandbox.orcid.org/0000-0003-0652-4625" },

                                                         { "creator_family_name" => "Testing",
                                                           "creator_given_name" => "Johnny",
                                                           "creator_name_type" => "Personal" }],
                                           "date_accepted" => ["2018-01-02"],
                                           "date_published" => ["1946-03-12"],
                                           "date_published_text" => nil,
                                           "date_submitted" => nil,
                                           "degree" => nil,
                                           "dewey" => nil,
                                           "doi" => "https://doi.org/10.18130/v3-k4an-w022",
                                           "duration" => ["duration1"],
                                           "edition" => ["1"],
                                           "eissn" => ["1234-5678"],
                                           "event_date" => nil,
                                           "event_location" => nil,
                                           "event_title" => nil,
                                           "extent" => nil,
                                           "files" => { "has_private_files" => false, "has_public_files" => false, "has_registered_files" => false },
                                           "funder" => nil,
                                           "funder_project_ref" => ["test"],
                                           "funding_description" => nil,
                                           "georeferenced" => nil,
                                           "institution" => ["British Library"],
                                           "irb_number" => nil,
                                           "irb_status" => nil,
                                           "is_format_of" => nil,
                                           "is_included_in" => nil,
                                           "isbn" => ["9781770460621"],
                                           "issn" => ["0987654321"],
                                           "issue" => nil,
                                           "journal_frequency" => nil,
                                           "journal_title" => ["Test Journal Title"],
                                           "keywords" => ["Lighthouses"],
                                           "language" => [],
                                           "latitude" => nil,
                                           "library_of_congress_classification" => nil,
                                           "license" => [],
                                           "location" => nil,
                                           "longitude" => nil,
                                           "medium" => nil,
                                           "mesh" => nil,
                                           "official_link" => ["http://test-url.com"],
                                           "official_url" => nil,
                                           "org_unit" => ["Department of Crackers"],
                                           "outcome" => nil,
                                           "page_display_order_number" => nil,
                                           "pagination" => ["1-2"],
                                           "part_of" => nil,
                                           "participant" => nil,
                                           "photo_caption" => nil,
                                           "photo_description" => nil,
                                           "place_of_publication" => ["Finland"],
                                           "prerequisites" => nil,
                                           "project_name" => ["Project name 1"],
                                           "publisher" => ["Schildts"],
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
                                           "related_url" => nil,
                                           "resource_type" => ["Book"],
                                           "rights_holder" => nil,
                                           "rights_statement" => [],
                                           "rights_statement_text" => nil,
                                           "series_name" => ["Series name"],
                                           "source" => [""],
                                           "subject" => nil,
                                           "subject_text" => nil,
                                           "suggested_reviewers" => nil,
                                           "suggested_student_reviewers" => nil,
                                           "table_of_contents" => nil,
                                           "thumbnail_url" => nil,
                                           "time" => nil,
                                           "title" => "Moomin",
                                           "type" => "work",
                                           "uuid" => work.id,
                                           "version" => ["3"],
                                           "visibility" => "open",
                                           "volume" => nil,
                                           "work_type" => "GenericWork",
                                           "workflow_status" => nil)
        end
      end
    end
  end
end
