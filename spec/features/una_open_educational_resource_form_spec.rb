# frozen_string_literal: true

require HykuAddons::Engine.root.join("spec", "support", "fill_in_fields.rb").to_s
require HykuAddons::Engine.root.join("spec", "support", "work_form_helpers.rb").to_s

RSpec.feature "Create a UnaArticle", js: true, slow: true do
  let(:work_type) { "una_article" }
  let(:work) { work_type.classify.constantize.find(work_uuid_from_url) }

  let(:model) { work_type.classify.constantize }
  let(:field_config) { "hyrax/#{work_type}_form".classify.constantize.field_configs }
  let(:user) { User.new(email: "test@example.com") { |u| u.save(validate: false) } }
  let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
  let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
  let(:workflow) { Sipity::Workflow.create!(active: true, name: "test-workflow", permission_template: permission_template) }
  let(:new_work_path) { "concern/#{work_type.to_s.pluralize}/new" }
  let(:permission_options) do
    { permission_template_id: permission_template.id, agent_type: "user", agent_id: user.user_key, access: "deposit" }
  end
  let(:headers) do
    {
      "Accept" => "application/json",
      "Accept-Encoding" => "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
      "User-Agent" => "Faraday v0.17.5"
    }
  end

  # The organisation option changes depending on the local, so we need to use this to ensure we select the right one
  let(:title) { "Ubiquity Template Work Item" }
  # The organisation option changes depending on the local, so we need to use this to ensure we select the right one
  let(:organisation_option) { HykuAddons::NameTypeService.new(model: model).active_elements.last }
  # The order of the items in each hash must match the order of the fields in the work form
  let(:creator) do
    [
      {
        creator_name_type: "Personal",
        creator_family_name: "Smithy",
        creator_given_name: "Johnny",
        creator_middle_name: "J.",
        creator_suffix: "Mr",
        creator_institution: "Test Org",
        creator_orcid: "0000-0000-1111-2222",
        creator_institutional_email: "test@test.com",
        creator_institutional_relationship: "Research associate",
        creator_role: "Actor",
        creator_isni: "56273930281",
        # This is a hidden field set in the form, but we want to be able to check its value is set
        creator_profile_visibility: User::PROFILE_VISIBILITY[:closed]
      },
      {
        creator_name_type: organisation_option["label"],
        creator_organization_name: "A Test Company Name",
        creator_ror: "ror.org/123456",
        creator_grid: "grid.org/098765",
        creator_wikidata: "wiki.com/123",
        creator_isni: "1234567890"
      }
    ]
  end
  let(:doi) { "10.1521/soco.23.1.118.59197" }

  let(:resource_type) { HykuAddons::ResourceTypesService.new(model: model).active_elements.sample(1) }
  let(:date_published) { { year: "2020", month: "02", day: "02" } }
  let(:date_submitted) { { year: "2019", month: "03", day: "03" } }
  let(:date_accepted) { { year: "2018", month: "04", day: "04" } }
  let(:keyword) { ["keyword1", "keyword2"] }
  let(:license_options) { HykuAddons::LicenseService.new(model: model).active_elements.sample(2) }
  let(:subject_options) { HykuAddons::SubjectService.new(model: model).active_elements.sample(2) }
  let(:abstract) { "This is the abstract text" }
  let(:journal_title) { "The journal title" }
  let(:alternative_journal_title) { ["Alt title 1", "Alt title 2"] }
  let(:volume) { ["1"] }
  let(:alternate_identifier) do
    [
      { alternate_identifier: "123456", alternate_identifier_type: "Alt Ident." },
      { alternate_identifier: "098765", alternate_identifier_type: "Alt Ident. 2" }
    ]
  end
  # NOTE: related_identifier isn't great, but the nested hash is difficult to store and refer to different hash values
  let(:related_identifier) { "123456" }
  let(:related_identifier_type_options) { HykuAddons::RelatedIdentifierTypeService.new(model: model).active_elements.sample(1) }
  let(:relation_type_options) { HykuAddons::RelationTypeService.new(model: model).active_elements.sample(1) }
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
  let(:refereed_options) { HykuAddons::RefereedService.new(model: model).active_elements.sample(1) }
  let(:add_info) { "Some additional information" }
  let(:irb_number) { "123" }
  let(:place_of_publication) { ["Place1", "Place2"].sample(1) }
  let(:publisher) { ["publisher1", "publisher2"].sample(1) }
  let(:issue) { "4" }
  let(:pagination) { "1-5" }
  let(:article_num) { "5" }
  let(:time) { "time" }
  let(:journal_frequency) { "journal_frequency" }
  let(:version_number) { ["3"] }
  let(:official_link) { "http://test312.com" }
  let(:library_of_congress_classification) { ["1234", "5678"] }
  let(:dewey) { "A Dewey Value" }
  let(:adapted_from) { "adapted_from" }
  let(:additional_links) { "http://link.com" }
  let(:related_material) { "related_material" }
  let(:issn) { "0987654321" }
  let(:eissn) { "e-1234567890" }
  let(:related_url) { ["http://test.com", "https://www.test123.com"] }

  before do
    Sipity::WorkflowAction.create!(name: "submit", workflow: workflow)
    Hyrax::PermissionTemplateAccess.create!(permission_options)

    login_as user
    visit new_work_path
  end

  context "when the form is filled out" do
    before do
      click_link "Descriptions"
      click_on "Additional fields"

      # Required fields
      fill_in_text_field(:title, title)
      fill_in_text_field(:doi, doi)
      fill_in_select(:resource_type, resource_type.map { |h| h["label"] }.first)
      fill_in_cloneable(:creator, creator)
      fill_in_date(:date_published, date_published)

      # Additional fields
      fill_in_multiple_text_fields(:keyword, keyword)
      fill_in_multiple_selects(:license, license_options.map { |h| h["label"] })
      fill_in_multiple_selects(:subject, subject_options.map { |h| h["label"] })
      fill_in_textarea(:abstract, abstract)
      fill_in_text_field(:journal_title, journal_title)
      fill_in_text_field(:alternative_journal_title, alternative_journal_title.first)
      fill_in_text_field(:volume, volume)

      fill_in_date(:date_accepted, date_accepted)
      fill_in_date(:date_submitted, date_submitted)
      fill_in_cloneable(:alternate_identifier, alternate_identifier)
      fill_in_cloneable(:related_identifier, related_identifier_label)
      fill_in_select(:refereed, refereed_options.map { |h| h["label"] }.first)
      fill_in_textarea(:add_info, add_info)
      fill_in_text_field(:irb_number, irb_number)
      fill_in_text_field(:publisher, publisher.first)
      fill_in_text_field(:place_of_publication, place_of_publication.first)
      fill_in_text_field(:issue, issue)
      fill_in_text_field(:pagination, pagination)
      fill_in_text_field(:article_num, article_num)
      fill_in_text_field(:time, time)
      fill_in_text_field(:journal_frequency, journal_frequency)
      fill_in_text_field(:version_number, version_number.first)
      fill_in_text_field(:official_link, official_link)
      fill_in_multiple_text_fields(:library_of_congress_classification, library_of_congress_classification)
      fill_in_text_field(:dewey, dewey)
      fill_in_textarea(:adapted_from, adapted_from)
      fill_in_text_field(:additional_links, additional_links)
      fill_in_textarea(:related_material, related_material)
      fill_in_text_field(:issn, issn)
      fill_in_text_field(:eissn, eissn)
      fill_in_multiple_text_fields(:related_url, related_url)
    end

    describe "submitting the form" do
      before do
        add_visibility
        add_agreement
        submit
      end

      it "redirects to the work show page" do
        # Ensure the basic data is being prenented and we're on the right page
        aggregate_failures "testing the saved data" do
          expect(page).to have_selector("h1", text: work_type.titleize, wait: 20)
          expect(page).to have_selector("h2", text: title, wait: 20)
          expect(page).to have_selector("span", text: "Public")
          expect(page).to have_content("Your files are being processed by Hyku in the background.")

          expect(page).to have_content(resource_type.map { |h| h["id"] }.first)
          expect(page).to have_content("#{creator.first.dig(:creator_family_name)}, #{creator.first.dig(:creator_given_name)}")
          %i[published accepted submitted].each { |d| expect(page).to have_content(normalize_date(send("date_#{d}".to_sym)).first) }
          expect(page).to have_content("https://doi.org/#{doi}")

          expect(work.title).to eq([title])
          expect(work.doi).to eq([doi])
          expect(work.resource_type).to eq(resource_type.map { |h| h["id"] })
          expect(work.date_published).to eq(normalize_date(date_published).first)
          # Cloneable fields use the label to select the option, but save the id to the work
          expect(work.creator).to eq([creator.to_json.gsub(organisation_option["label"], organisation_option["id"])])
          expect(work.keyword).to eq(keyword)
          expect(work.license).to eq(license_options.map { |h| h["id"] })
          expect(work.subject).to eq(subject_options.map { |h| h["id"] })
          expect(work.abstract).to eq(abstract)
          expect(work.journal_title).to eq(journal_title)
          expect(work.alternative_journal_title).to eq(alternative_journal_title.take(1))
          expect(work.volume).to eq(volume)
          expect(work.date_accepted).to eq(normalize_date(date_accepted).first)
          expect(work.date_submitted).to eq(normalize_date(date_submitted).first)
          expect(work.alternate_identifier.first).to eq(alternate_identifier.to_json)
          expect(work.related_identifier.first).to eq(related_identifier_id.to_json)
          expect(work.refereed).to eq(refereed_options.map { |h| h["id"] }.first)
          expect(work.add_info).to eq(add_info)
          expect(work.irb_number).to eq(irb_number)
          expect(work.publisher).to eq(publisher)
          expect(work.place_of_publication).to eq(place_of_publication)
          expect(work.issue).to eq(issue)
          expect(work.pagination).to eq(pagination)
          expect(work.article_num).to eq(article_num)
          expect(work.time).to eq(time)
          expect(work.journal_frequency).to eq(journal_frequency)
          expect(work.version_number).to eq(version_number)
          expect(work.official_link).to eq(official_link)
          expect(work.library_of_congress_classification).to eq(library_of_congress_classification)
          expect(work.dewey).to eq(dewey)
          expect(work.adapted_from).to eq(adapted_from)
          expect(work.additional_links).to eq(additional_links)
          expect(work.related_material).to eq(related_material)
          expect(work.issn).to eq(issn)
          expect(work.eissn).to eq(eissn)
          expect(work.related_url).to eq(related_url)
        end
      end
    end
  end
end
