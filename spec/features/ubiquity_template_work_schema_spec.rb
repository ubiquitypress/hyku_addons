# frozen_string_literal: true

require "rails_helper"
require HykuAddons::Engine.root.join("spec", "helpers", "fill_in_fields.rb").to_s
require HykuAddons::Engine.root.join("spec", "helpers", "work_form_helpers.rb").to_s

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
        creator_middle_name: "J.",
        creator_suffix: "Mr",
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
      {
        contributor_name_type: "Personal",
        contributor_family_name: "Johnny",
        contributor_given_name: "Smithy",
        contributor_orcid: "0000-1111-2222-3333",
        contributor_institutional_relationship: "Staff member",
        contributor_isni: "1234567890"
      },
      {
        contributor_name_type: "Organisational",
        contributor_organization_name: "A Test Company Name",
        contributor_ror: "ror.org/1234",
        contributor_grid: "grid.com/1234",
        contributor_wikidata: "wikidata.org/1234",
        contributor_isni: "1234567890"
      }
    ]
  end
  let(:editor_given_name1) { "Joanna" }
  let(:editor_family_name1) { "Smithy" }
  let(:editor_organization_name) { "A Test Company Name" }
  let(:organisation_option) { HykuAddons::NameTypeService.new.active_elements.last }
  let(:editor) do
    [
      {
        editor_name_type: "Personal",
        editor_family_name: editor_family_name1,
        editor_given_name: editor_given_name1,
        editor_orcid: "0000-1111-2222-3333",
        editor_institutional_relationship: "Staff member",
        editor_isni: "1234567890"
      },
      {
        editor_name_type: organisation_option["label"],
        editor_organization_name: editor_organization_name,
        editor_isni: "0987654321"
      }
    ]
  end
  let(:resource_type) { HykuAddons::ResourceTypesService.new.active_elements.sample(1) }
  let(:date_published) { { year: "2020", month: "02", day: "02" } }
  let(:date_submitted) { { year: "2019", month: "03", day: "03" } }
  let(:date_accepted) { { year: "2018", month: "04", day: "04" } }
  let(:source_data) { ["source 1", "Source 2"] }
  let(:description) { ["This is the first text description", "This is the second text description"] }
  let(:keyword) { ["keyword1", "keyword2"] }
  let(:license_options) { HykuAddons::LicenseService.new.active_elements.sample(2) }
  let(:rights_statement_options) { HykuAddons::RightsStatementService.new.active_elements.sample(1) }
  let(:publisher) { ["publisher1", "publisher2"] }
  let(:subject_options) { HykuAddons::SubjectService.new.active_elements.sample(2) }
  let(:language_options) { HykuAddons::LanguageService.new.active_elements.sample(2) }
  let(:related_url) { ["http://test.com", "https://www.test123.com"] }
  let(:abstract) { "This is the abstract text" }
  let(:media) { ["Audio", "Video"] }
  let(:duration) { ["1 minute", "7 hours"] }
  let(:institution_options) { HykuAddons::InstitutionService.new.active_elements.sample(2) }
  let(:org_unit) { ["Unit1", "Unit2"] }
  let(:project_name) { ["Project1", "Project2"] }
  let(:funder) do
    [
      {
        funder_name: "A funder",
        funder_doi: "doi.org/123456",
        funder_isni: "0987654321",
        funder_ror: "ror.org/123456678",
        funder_award: ["Award1"]
      },
      {
        funder_name: "Another funder",
        funder_doi: "doi.org/098765",
        funder_isni: "1234567890",
        funder_ror: "ror.org/345678976543",
        funder_award: ["Award2"]
      }
    ]
  end
  let(:fndr_project_ref) { ["Ref1", "Ref2"] }
  let(:event_title) { ["Event1", "Event2"] }
  let(:event_location) { ["Location1", "Location2"] }
  let(:event_date) { [{ year: "2022", month: "02", day: "02" }, { year: "2023", month: "03", day: "03" }] }
  let(:series_name) { ["Series1", "Series2"] }
  let(:book_title) { "The book title" }
  let(:journal_title) { "The journal title" }
  let(:alternative_journal_title) { ["Alt title 1", "Alt title 2"] }
  let(:volume) { ["1"] }
  let(:edition) { "2" }
  let(:version_number) { ["3"] }
  let(:issue) { "4" }
  let(:pagination) { "1-5" }
  let(:article_num) { "5" }
  let(:place_of_publication) { ["Place1", "Place2"] }
  let(:isbn) { "1234567890" }
  let(:issn) { "0987654321" }
  let(:eissn) { "e-1234567890" }
  let(:official_link) { "http://test312.com" }
  let(:current_he_institution_service) { HykuAddons::CurrentHeInstitutionService.new }
  let(:current_he_institution_element) { current_he_institution_service.active_elements.sample }
  let(:current_he_institution_index) { current_he_institution_service.active_elements.index(current_he_institution_element) }
  let(:current_he_institution_input) do
    [
      {
        current_he_institution_name: current_he_institution_element["label"]
      }
    ]
  end
  let(:current_he_institution_data) do
    [
      {
        current_he_institution_name: current_he_institution_element["label"],
        current_he_institution_ror: current_he_institution_service.select_active_options_ror[current_he_institution_index],
        current_he_institution_isni: current_he_institution_service.select_active_options_isni[current_he_institution_index]
      }
    ]
  end
  let(:related_exhibition) { ["Exhibition1", "Exhibition2"] }
  let(:related_exhibition_venue) { ["Exhibition venue 1", "Exhibition venue 2"] }
  let(:related_exhibition_date) { [{ year: "2022", month: "02", day: "02" }, { year: "2023", month: "03", day: "03" }] }
  let(:rights_holder) { ["Holder1", "Holder2"] }
  let(:qualification_name_options) { HykuAddons::QualificationNameService.new.active_elements.sample(1) }
  let(:qualification_level_options) { HykuAddons::QualificationLevelService.new.active_elements.sample(1) }
  let(:alternate_identifier) do
    [
      { alternate_identifier: "123456", alternate_identifier_type: "Alt Ident." },
      { alternate_identifier: "098765", alternate_identifier_type: "Alt Ident. 2" }
    ]
  end
  # NOTE: related_identifier isn't great, but the nested hash is difficult to store and refer to different hash values
  let(:related_identifier) { "123456" }
  let(:related_identifier_type_options) { HykuAddons::RelatedIdentifierTypeService.new.active_elements.sample(1) }
  let(:relation_type_options) { HykuAddons::RelationTypeService.new.active_elements.sample(1) }
  let(:related_identifier_label) do
    [
      {
        related_identifier: related_identifier,
        related_identifier_type: related_identifier_type_options.map { |h| h["label"] }.first,
        relation_type: relation_type_options.map { |h| h["label"] }.first
      }
    ]
  end
  let(:related_identifier_id) do
    [
      {
        related_identifier: related_identifier,
        related_identifier_type: related_identifier_type_options.map { |h| h["id"] }.first,
        relation_type: relation_type_options.map { |h| h["id"] }.first
      }
    ]
  end
  let(:refereed_options) { HykuAddons::RefereedService.new.active_elements.sample(1) }
  let(:dewey) { "A Dewey Value" }
  let(:library_of_congress_classification) { ["1234", "5678"] }
  let(:add_info) { "Some additional information" }
  let(:page_display_order_number) { "1" }
  let(:irb_number) { "123" }
  let(:irb_status_options) { HykuAddons::IrbStatusService.new.active_elements.sample(1) }
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
  let(:audience_options) { HykuAddons::AudienceService.new.active_elements.sample(2) }
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
  let(:georeferenced_options) { HykuAddons::GeoreferencedService.new.active_elements.sample(1) }

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

      # Required fields
      fill_in_text_field(:title, title)
      fill_in_multiple_text_fields(:alt_title, alt_title)
      fill_in_select(:resource_type, resource_type.map { |h| h["label"] }.first)
      fill_in_cloneable(:creator, creator)
      fill_in_date(:date_published, date_published)
      fill_in_cloneable(:contributor, contributor)

      # Additional fields
      fill_in_multiple_textareas(:description, description)
      fill_in_multiple_text_fields(:keyword, keyword)
      fill_in_multiple_selects(:license, license_options.map { |h| h["label"] })
      fill_in_select(:rights_statement, rights_statement_options.map { |h| h["label"] }.first)
      fill_in_multiple_text_fields(:publisher, publisher)
      fill_in_multiple_selects(:subject, subject_options.map { |h| h["label"] })
      fill_in_multiple_selects(:language, language_options.map { |h| h["label"] })
      fill_in_multiple_text_fields(:related_url, related_url)
      fill_in_multiple_text_fields(:source, source_data)
      # # NOTE: based_near uses select2 which cannot be tested with capybara
      # fill_in_multiple_select2(:based_near, based_near)
      fill_in_textarea(:abstract, abstract)
      fill_in_multiple_text_fields(:media, media)
      fill_in_multiple_text_fields(:duration, duration)
      fill_in_multiple_selects(:institution, institution_options.map { |h| h["label"] })
      fill_in_multiple_text_fields(:org_unit, org_unit)
      fill_in_multiple_text_fields(:project_name, project_name)
      fill_in_cloneable(:funder, funder)
      fill_in_multiple_text_fields(:fndr_project_ref, fndr_project_ref)
      fill_in_multiple_text_fields(:event_title, event_title)
      fill_in_multiple_text_fields(:event_location, event_location)
      fill_in_date(:event_date, event_date)
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
      fill_in_legacy_json_field(:current_he_institution, current_he_institution_input)
      fill_in_date(:date_accepted, date_accepted)
      fill_in_date(:date_submitted, date_submitted)
      fill_in_text_field(:official_link, official_link)
      fill_in_multiple_text_fields(:related_exhibition, related_exhibition)
      fill_in_multiple_text_fields(:related_exhibition_venue, related_exhibition_venue)
      fill_in_date(:related_exhibition_date, related_exhibition_date)
      fill_in_multiple_text_fields(:rights_holder, rights_holder)
      fill_in_multiple_text_fields(:related_exhibition_venue, related_exhibition_venue)
      fill_in_select(:qualification_name, qualification_name_options.map { |h| h["label"] }.first)
      fill_in_select(:qualification_level, qualification_level_options.map { |h| h["label"] }.first)
      fill_in_cloneable(:alternate_identifier, alternate_identifier)
      fill_in_cloneable(:related_identifier, related_identifier_label)
      fill_in_select(:refereed, refereed_options.map { |h| h["label"] }.first)
      fill_in_text_field(:dewey, dewey)
      fill_in_multiple_text_fields(:library_of_congress_classification, library_of_congress_classification)
      fill_in_textarea(:add_info, add_info)
      fill_in_text_field(:page_display_order_number, page_display_order_number)
      fill_in_text_field(:irb_number, irb_number)
      fill_in_select(:irb_status, irb_status_options.map { |h| h["label"] }.first)
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
      fill_in_multiple_selects(:audience, audience_options.map { |h| h["label"] })
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
      fill_in_select(:georeferenced, georeferenced_options.map { |h| h["label"] }.first)
    end

    describe "submitting the form" do
      before do
        add_visibility
        add_agreement
        submit
      end

      it "redirects to the work show page" do
        # Ensure the basic data is being prenented and we're on the right page
        expect(page).to have_selector("h1", text: work_type.titleize, wait: 5)
        expect(page).to have_selector("h2", text: title, wait: 5)
        expect(page).to have_selector("span", text: "Public")
        expect(page).to have_content("Your files are being processed by Hyku in the background.")

        expect(page).to have_content(resource_type.map { |h| h["id"] }.first)
        alt_title.each { |at| expect(page).to have_content(at) }
        expect(page).to have_content("#{creator.first.dig(:creator_family_name)}, #{creator.first.dig(:creator_given_name)}")
        expect(page).to have_content("#{contributor.first.dig(:contributor_family_name)}, #{contributor.first.dig(:contributor_given_name)}")
        %i[published accepted submitted].each { |d| expect(page).to have_content(normalize_date(send("date_#{d}".to_sym)).first) }
        duration.each { |at| expect(page).to have_content(at) }
        description.each { |at| expect(page).to have_content(at) }

        # Get the actual work from the URL param
        current_uri = URI.parse(page.current_url)
        work_id = current_uri.path.split("/").last
        work = work_type.classify.constantize.find(work_id)

        expect(work.title).to eq([title])
        expect(work.resource_type).to eq(resource_type.map { |h| h["id"] })
        expect(work.date_published).to eq(normalize_date(date_published).first)
        # Cloneable fields use the label to select the option, but save the id to the work
        expect(work.creator).to eq([creator.to_json.gsub(organisation_option["label"], organisation_option["id"])])
        expect(work.contributor).to eq([contributor.to_json.gsub(organisation_option["label"], organisation_option["id"])])
        expect(work.editor).to eq([editor.to_json.gsub(organisation_option["label"], organisation_option["id"])])
        expect(work.description).to eq(description)
        expect(work.keyword).to eq(keyword)
        expect(work.source).to eq(source_data)
        expect(work.license).to eq(license_options.map { |h| h["id"] })
        expect(work.rights_statement).to eq(rights_statement_options.map { |h| h["id"] })
        expect(work.publisher).to eq(publisher)
        expect(work.subject).to eq(subject_options.map { |h| h["id"] })
        expect(work.language).to eq(language_options.map { |h| h["id"] })
        expect(work.related_url).to eq(related_url)
        expect(work.source).to eq(source_data)
        expect(work.abstract).to eq(abstract)
        expect(work.media).to eq(media)
        expect(work.duration).to eq(duration)
        expect(work.institution).to eq(institution_options.map { |h| h["id"] })
        expect(work.org_unit).to eq(org_unit)
        expect(work.project_name).to eq(project_name)
        expect(work.funder).to eq([funder.to_json])
        expect(work.fndr_project_ref).to eq(fndr_project_ref)
        expect(work.event_title).to eq(event_title)
        expect(work.event_location).to eq(event_location)
        expect(work.event_date).to eq(event_date.map { |date| normalize_date(date) }.flatten)
        expect(work.series_name).to eq(series_name)
        expect(work.book_title).to eq(book_title)
        expect(work.journal_title).to eq(journal_title)
        expect(work.alternative_journal_title).to eq(alternative_journal_title)
        expect(work.volume).to eq(volume)
        expect(work.edition).to eq(edition)
        expect(work.version_number).to eq(version_number)
        expect(work.issue).to eq(issue)
        expect(work.pagination).to eq(pagination)
        expect(work.article_num).to eq(article_num)
        expect(work.place_of_publication).to eq(place_of_publication)
        expect(work.isbn).to eq(isbn)
        expect(work.issn).to eq(issn)
        expect(work.eissn).to eq(eissn)
        # We need to test the first item or an ActiveTripple::Relation is returned
        expect(work.current_he_institution.first).to eq(current_he_institution_data.to_json)
        expect(work.date_accepted).to eq(normalize_date(date_accepted).first)
        expect(work.date_submitted).to eq(normalize_date(date_submitted).first)
        expect(work.official_link).to eq(official_link)
        expect(work.related_exhibition).to eq(related_exhibition)
        expect(work.related_exhibition_venue).to eq(related_exhibition_venue)
        expect(work.related_exhibition_date).to eq(related_exhibition_date.map { |date| normalize_date(date) }.flatten)
        expect(work.rights_holder).to eq(rights_holder)
        expect(work.related_exhibition_venue).to eq(related_exhibition_venue)
        expect(work.qualification_name).to eq(qualification_name_options.map { |h| h["id"] }.first)
        expect(work.qualification_level).to eq(qualification_level_options.map { |h| h["id"] }.first)
        expect(work.alternate_identifier.first).to eq(alternate_identifier.to_json)
        expect(work.related_identifier.first).to eq(related_identifier_id.to_json)
        expect(work.refereed).to eq(refereed_options.map { |h| h["id"] }.first)
        expect(work.dewey).to eq(dewey)
        expect(work.library_of_congress_classification).to eq(library_of_congress_classification)
        expect(work.add_info).to eq(add_info)
        expect(work.page_display_order_number).to eq(page_display_order_number)
        expect(work.irb_number).to eq(irb_number)
        expect(work.irb_status).to eq(irb_status_options.map { |h| h["id"] }.first)
        expect(work.additional_links).to eq(additional_links)
        expect(work.is_included_in).to eq(is_included_in)
        expect(work.buy_book).to eq(buy_book)
        expect(work.challenged).to eq(challenged)
        expect(work.outcome).to eq(outcome)
        expect(work.participant).to eq(participant)
        expect(work.reading_level).to eq(reading_level)
        expect(work.photo_caption).to eq(photo_caption)
        expect(work.photo_description).to eq(photo_description)
        expect(work.degree).to eq(degree)
        expect(work.longitude).to eq(longitude)
        expect(work.latitude).to eq(latitude)
        expect(work.alt_email).to eq(alt_email)
        expect(work.alt_book_title).to eq(alt_book_title)
        expect(work.table_of_contents).to eq(table_of_contents)
        expect(work.prerequisites).to eq(prerequisites)
        expect(work.suggested_student_reviewers).to eq(suggested_student_reviewers)
        expect(work.suggested_reviewers).to eq(suggested_reviewers)
        expect(work.adapted_from).to eq(adapted_from)
        expect(work.audience).to eq(audience_options.map { |h| h["id"] })
        expect(work.related_material).to eq(related_material)
        expect(JSON.parse(work.note.first).dig("note")).to eq(note)
        expect(work.advisor).to eq(advisor)
        expect(work.subject_text).to eq(subject_text)
        expect(work.mesh).to eq(mesh)
        expect(work.journal_frequency).to eq(journal_frequency)
        expect(work.funding_description).to eq(funding_description)
        expect(work.citation).to eq(citation)
        expect(work.references).to eq(references)
        expect(work.extent).to eq(extent)
        expect(work.medium).to eq(medium)
        expect(work.committee_member).to eq(committee_member)
        expect(work.time).to eq(time)
        expect(work.qualification_grantor).to eq(qualification_grantor)
        expect(work.date_published_text).to eq(date_published_text)
        expect(work.rights_statement_text).to eq(rights_statement_text)
        expect(work.qualification_subject_text).to eq(qualification_subject_text)
        expect(work.georeferenced).to eq(georeferenced_options.map { |h| h["id"] }.first.to_s)
      end
    end
  end
end
