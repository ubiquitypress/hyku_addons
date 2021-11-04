# frozen_string_literal: true

# require File.expand_path("../helpers/create_ubiquity_template_user_context", __dir__)
require "rails_helper"
require HykuAddons::Engine.root.join("spec", "helpers", "fill_in_fields.rb").to_s

include Warden::Test::Helpers

RSpec.feature "Create a UbiquityTemplateWork", js: true do
  let(:work_type) { "ubiquity_template_work" }
  let(:field_config) { "hyrax/#{work_type}_form".classify.constantize.field_configs }

  let(:user) { User.new(email: "test@example.com") { |u| u.save(validate: false) } }
  let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
  let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
  let(:workflow) { Sipity::Workflow.create!(active: true, name: "test-workflow", permission_template: permission_template) }
  let(:new_work_path) { "concern/#{work_type.to_s.pluralize}/new" }
  let(:permission_options) do
    { permission_template_id: permission_template.id, agent_type: "user", agent_id: user.user_key, access: "deposit" }
  end

  let(:title) { "Ubiquity Template Work Item" }
  let(:alt_title) { ["Alt Title 1", "Alt Title 2"] }
  let(:creator) do
    [
      {
        creator_name_type: "Personal",
        creator_family_name: "Johnny",
        creator_given_name: "Smithy",
        creator_orcid: "0000-0000-1111-2222",
        creator_institutional_relationship: "Research associate",
        creator_isni: "56273930281"
      },
      {
        creator_name_type: "Organisational",
        creator_organization_name: "A Test Company Name",
        creator_ror: "ror.org/123456",
        creator_grid: "grid.org/098765",
        creator_wikidata: "wiki.com/123",
        creator_isni: "1234567890"
      }
    ]
  end
  let(:contributor) do
    [
      { contributor_name_type: "Personal", contributor_family_name: "Johnny", contributor_given_name: "Smithy" },
      { contributor_name_type: "Organisational", contributor_organization_name: "A Test Company Name" }
    ]
  end
  let(:resource_type) { "Other" }
  let(:date_published) { { year: "2020", month: "02", day: "02" } }
  let(:date_submitted) { { year: "2019", month: "03", day: "03" } }
  let(:date_accepted) { { year: "2018", month: "04", day: "04" } }
  let(:source) { ["source 1", "Source 2"] }
  let(:description) { ["This is the first text description", "This is the second text description"] }
  let(:keyword) { ["keyword1", "keyword2"] }
  let(:license) { HykuAddons::LicenseService.new.active_elements.map { |h| h["label"] }.first(2) }
  let(:rights_statement) { HykuAddons::RightsStatementService.new.active_elements.map { |h| h["label"] }.first }
  let(:publisher) { ["publisher1", "publisher2"] }
  let(:subject) { HykuAddons::SubjectService.new.active_elements.map { |h| h["label"] }.first(2) }
  let(:language) { HykuAddons::LanguageService.new.active_elements.map { |h| h["label"] }.first(2) }
  let(:identifier) { "Work Identifier" }
  let(:related_url) { ["http://test.com", "https://www.test123.com"] }
  let(:source) { ["Source1", "Source2"] }
  let(:abstract) { "This is the abstract text" }
  let(:media) { ["Audio", "Video"] }
  let(:duration) { ["1 minute", "7 hours"] }
  let(:institution) { HykuAddons::InstitutionService.new.active_elements.map { |h| h["label"] }.first(2) }
  let(:org_unit) { ["Unit1", "Unit2"] }
  let(:project_name) { ["Project1", "Project2"] }
  let(:funder) do
    [
      { funder_name: "A funder", funder_doi: "doi.org/123456", funder_isni: "0987654321", funder_ror: "ror.org/123456678" },
      { funder_name: "Another funder", funder_doi: "doi.org/098765", funder_isni: "1234567890", funder_ror: "ror.org/345678976543" }
    ]
  end
  let(:fndr_project_ref) { ["Ref1", "Ref2"] }
  let(:event_title) { ["Event1", "Event2"] }
  let(:event_location) { ["Location1", "Location2"] }
  let(:event_date) { [{ year: "2022", month: "02", day: "02" }, { year: "2023", month: "03", day: "03" }] }
  let(:series_name) { ["Series1", "Series2"] }
  let(:book_title) { "The book title" }
  let(:editor_given_name1) { "Joanna" }
  let(:editor_family_name1) { "Smithy" }
  let(:editor_organization_name) { "A Test Company Name" }
  let(:editor) do
    [
      { editor_name_type: "Personal", editor_family_name: editor_family_name1, editor_given_name: editor_given_name1 },
      { editor_name_type: "Organisational", editor_organization_name: editor_organization_name }
    ]
  end
  let(:journal_title) { "The journal title" }
  let(:alternative_journal_title) { ["Alt title 1", "Alt title 2"] }
  let(:volume) { "1" }
  let(:edition) { "2" }
  let(:version_number) { "3" }
  let(:issue) { "4" }
  let(:pagination) { "1-5" }
  let(:article_num) { "5" }
  let(:place_of_publication) { ["Place1", "Place2"] }
  let(:isbn) { "1234567890" }
  let(:issn) { "0987654321" }
  let(:eissn) { "e-1234567890" }
  let(:official_link) { "http://test312.com" }
  let(:current_he_institution) { HykuAddons::CurrentHeInstitutionService.new.active_elements.map { |h| h["label"] }.first(2) }
  let(:related_exhibition) { ["Exhibition1", "Exhibition2"] }
  let(:related_exhibition_venue) { ["Exhibition venue 1", "Exhibition venue 2"] }
  let(:rights_holder) { ["Holder1", "Holder2"] }
  let(:doi) { ["doi.org/something", "doi.org/something-esle"] }
  let(:qualification_name) { HykuAddons::QualificationNameService.new.active_elements.map { |h| h["label"] }.first }
  let(:qualification_level) { HykuAddons::QualificationLevelService.new.active_elements.map { |h| h["label"] }.first }
  let(:refereed) { HykuAddons::RefereedService.new.active_elements.map { |h| h["label"] }.first }
  let(:dewey) { "A Dewey Value" }
  let(:library_of_congress_classification) { ["1234", "5678"] }
  let(:add_info) { "Some additional information" }
  let(:page_display_order_number) { "1" }
  let(:irb_number) { "123" }
  let(:irb_status) { HykuAddons::IrbStatusService.new.active_elements.map { |h| h["label"] }.first }
  let(:additional_links) { "http://link.com" }
  let(:is_included_in) { "1" }
  let(:buy_book) { "1" }
  let(:challenged) { "1" }
  let(:outcome) { "Outcome" }
  let(:participant) { "Participant" }
  let(:reading_level) { "Adult" }
  let(:photo_caption) { "Caption1" }
  let(:photo_description) { "Description1" }
  let(:degree) { "Degree Name" }
  let(:longitude) { "0.124356" }
  let(:latitude) { "1.345678" }
  let(:alt_email) { ["email@test.com", "another@test.com"] }
  let(:alt_book_title) { "Another title" }
  let(:table_of_contents) { "table_of_contents" }
  let(:prerequisites) { "prerequisites" }
  let(:suggested_student_reviewers) { "suggested_student_reviewers" }
  let(:suggested_reviewers) { "suggested_reviewers" }
  let(:adapted_from) { "adapted_from" }
  let(:audience) { HykuAddons::AudienceService.new.active_elements.map { |h| h["label"] }.first(2) }
  let(:related_material) { "related_material" }

  let(:note) { ["note1", "note2"] }
  let(:advisor) { "advisor" }
  let(:subject_text) { ["subject1", "subject2"] }
  let(:mesh) { ["mesh1", "mesh2"] }
  let(:journal_frequency) { "journal_frequency" }
  let(:funding_description) { ["Funding descrption 1", "Funding descrption 2"] }
  let(:citation) { ["citation1", "citation2"] }
  let(:references) { ["references1", "references2"] }
  let(:extent) { "extent" }
  let(:medium) { ["medium1", "medium2"] }
  let(:committee_member) { ["Commitee member 1", "Commitee member 2"] }
  let(:time) { "time" }
  let(:qualification_grantor) { "qualification_grantor" }
  let(:date_published_text) { "date_published_text" }
  let(:rights_statement_text) { "rights_statement_text" }
  let(:qualification_subject_text) { ["Qualification statement text 1", "Qualification statement text 2"] }
  let(:georeferenced) { HykuAddons::GeoreferencedService.new.active_elements.map { |h| h["label"] }.first }

  before do
    Sipity::WorkflowAction.create!(name: "submit", workflow: workflow)
    Hyrax::PermissionTemplateAccess.create!(permission_options)

    stub_request(:get, "http://api.crossref.org/funders?query=A%20funder")
      .with(headers: {
              "Accept" => "application/json",
              "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
              "User-Agent" => "Faraday v0.17.4"
            })
      .to_return(status: 200, body: "", headers: {})

    stub_request(:get, "http://api.crossref.org/funders?query=Another%20funder")
      .with(headers: {
              "Accept" => "application/json",
              "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
              "User-Agent" => "Faraday v0.17.4"
            })
      .to_return(status: 200, body: "", headers: {})

    login_as user
    visit new_work_path
  end

  context "when the form is filled out" do
    before do
      click_link "Descriptions"
      click_on "Additional fields"

      fill_in_text_field(:title, title)
      fill_in_multiple_text_fields(:alt_title, alt_title)
      fill_in_select(:resource_type, resource_type)
      fill_in_date_field(:date_published, date_published)
      fill_in_cloneable(:creator, creator)
      fill_in_cloneable(:contributor, contributor)
      fill_in_multiple_textareas(:description, description)
      fill_in_multiple_text_fields(:keyword, keyword)
      fill_in_multiple_text_fields(:source, source)
      fill_in_multiple_selects(:license, license)
      fill_in_select(:rights_statement, rights_statement)
      fill_in_multiple_text_fields(:publisher, publisher)
      fill_in_multiple_selects(:subject, subject)
      fill_in_multiple_selects(:language, language)
      fill_in_text_field(:identifier, identifier)
      fill_in_multiple_text_fields(:related_url, related_url)
      fill_in_multiple_text_fields(:source, source)
      # NOTE: based_near uses select2 which cannot be tested with capybara
      # fill_in_multiple_select2(:based_near, based_near)
      fill_in_textarea(:abstract, abstract)
      fill_in_multiple_text_fields(:media, media)
      fill_in_multiple_text_fields(:duration, duration)
      fill_in_multiple_selects(:institution, institution)
      fill_in_multiple_text_fields(:org_unit, org_unit)
      fill_in_multiple_text_fields(:project_name, project_name)
      fill_in_funder(funder)
      fill_in_multiple_text_fields(:fndr_project_ref, fndr_project_ref)
      fill_in_multiple_text_fields(:event_title, event_title)
      fill_in_multiple_text_fields(:event_location, event_location)
      fill_in_cloneable_date_field(:event_date, event_date)
      fill_in_multiple_text_fields(:series_name, series_name)
      fill_in_text_field(:book_title, book_title)
      fill_in_cloneable(:editor, editor)
      fill_in_text_field(:journal_title, journal_title)
      fill_in_multiple_text_fields(:alternative_journal_title, alternative_journal_title)
      fill_in_text_field(:volume, volume)
      fill_in_text_field(:edition, edition)
      fill_in_text_field(:version_number, version_number)
      fill_in_text_field(:issue, issue)
      fill_in_text_field(:pagination, pagination)
      fill_in_text_field(:article_num, article_num)
      fill_in_multiple_text_fields(:place_of_publication, place_of_publication)
      fill_in_text_field(:isbn, isbn)
      fill_in_text_field(:issn, issn)
      fill_in_text_field(:eissn, eissn)
      # TODO: - current_he_institution is a legacy JSON field and needs updating
      # fill_in_select(:current_he_institution, current_he_institution)
      fill_in_date_field(:date_accepted, date_accepted)
      fill_in_date_field(:date_submitted, date_submitted)
      fill_in_text_field(:official_link, official_link)
      fill_in_multiple_text_fields(:related_exhibition, related_exhibition)
      fill_in_multiple_text_fields(:related_exhibition_venue, related_exhibition_venue)
      # TODO: - related Exhibition date
      fill_in_multiple_text_fields(:rights_holder, rights_holder)
      fill_in_multiple_text_fields(:related_exhibition_venue, related_exhibition_venue)
      fill_in_multiple_text_fields(:doi, doi)
      fill_in_select(:qualification_name, qualification_name)
      fill_in_select(:qualification_level, qualification_level)
      fill_in_select(:refereed, refereed)
      fill_in_text_field(:dewey, dewey)
      fill_in_multiple_text_fields(:library_of_congress_classification, library_of_congress_classification)
      fill_in_textarea(:add_info, add_info)
      fill_in_text_field(:page_display_order_number, page_display_order_number)
      fill_in_text_field(:irb_number, irb_number)
      fill_in_select(:irb_status, irb_status)
      fill_in_text_field(:additional_links, additional_links)
      fill_in_text_field(:is_included_in, is_included_in)
      fill_in_text_field(:buy_book, buy_book)
      fill_in_text_field(:challenged, challenged)
      fill_in_text_field(:outcome, outcome)
      fill_in_text_field(:participant, participant)
      fill_in_text_field(:reading_level, reading_level)
      fill_in_text_field(:photo_caption, photo_caption)
      fill_in_text_field(:photo_description, photo_description)
      fill_in_text_field(:degree, degree)
      fill_in_text_field(:longitude, longitude)
      fill_in_text_field(:latitude, latitude)
      fill_in_multiple_text_fields(:alt_email, alt_email)
      fill_in_text_field(:alt_book_title, alt_book_title)
      fill_in_textarea(:table_of_contents, table_of_contents)
      fill_in_textarea(:prerequisites, prerequisites)
      fill_in_textarea(:suggested_student_reviewers, suggested_student_reviewers)
      fill_in_textarea(:suggested_reviewers, suggested_reviewers)
      fill_in_textarea(:adapted_from, adapted_from)
      fill_in_multiple_selects(:audience, audience)
      fill_in_textarea(:related_material, related_material)
      fill_in_multiple_text_fields(:note, note)
      fill_in_text_field(:advisor, advisor)
      fill_in_multiple_text_fields(:subject_text, subject_text)
      fill_in_multiple_text_fields(:mesh, mesh)
      fill_in_text_field(:journal_frequency, journal_frequency)
      fill_in_multiple_text_fields(:funding_description, funding_description)
      fill_in_multiple_text_fields(:citation, citation)
      fill_in_multiple_text_fields(:references, references)
      fill_in_text_field(:extent, extent)
      fill_in_multiple_text_fields(:medium, medium)
      fill_in_multiple_text_fields(:committee_member, committee_member)
      fill_in_text_field(:time, time)
      fill_in_text_field(:qualification_grantor, qualification_grantor)
      fill_in_text_field(:date_published_text, date_published_text)
      fill_in_text_field(:rights_statement_text, rights_statement_text)
      fill_in_multiple_text_fields(:qualification_subject_text, qualification_subject_text)
      fill_in_select(:georeferenced, georeferenced)
    end

    describe "filling in the form" do
      it "fills in each field" do
        ss
      end
    end
  end
end
