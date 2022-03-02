# frozen_string_literal: true

require HykuAddons::Engine.root.join("spec", "support", "fill_in_fields.rb").to_s
require HykuAddons::Engine.root.join("spec", "support", "work_form_helpers.rb").to_s

RSpec.feature "Create a UbiquityTemplateWork", js: true, slow: true do
  let(:work_type) { "anschutz_work" }
  let(:work) { work_type.classify.constantize.find(work_uuid_from_url) }

  let(:site) do
    account = build_stubbed(:account)
    # Set the locale for this work to ensure our authorities use the right values
    account.settings = account.settings.merge(locale_name: "anschutz")

    Site.new(account: account)
  end

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

  let(:title) { "Ubiquity Template Work Item" }
  let(:alt_title) { ["Alt Title 1", "Alt Title 2"] }
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
        creator_role: ["Actor"],
        creator_institution: ["Test Org"],
        creator_orcid: "0000-0000-1111-2222",
        creator_institutional_email: "test@test.com",
        # This is a hidden field set in the form, but we want to be able to check its value is set
        creator_profile_visibility: User::PROFILE_VISIBILITY[:closed]
      },
      {
        creator_name_type: organisation_option["label"],
        creator_organization_name: "A Test Company Name",
        creator_ror: "ror.org/123456",
        creator_grid: "grid.org/098765",
        creator_wikidata: "wiki.com/123"
      }
    ]
  end
  let(:abstract) { "Some additional information 123" }
  let(:date_published) { { year: "2020", month: "02", day: "02" } }
  let(:date_published_text) { "date_published_text" }
  let(:resource_type) { HykuAddons::ResourceTypesService.new(model: model).active_elements.sample(1) }
  let(:license_options) { HykuAddons::LicenseService.new(model: model).active_elements.sample(2) }
  let(:place_of_publication) { ["Place1", "Place2"] }
  let(:language_options) { HykuAddons::LanguageService.new(model: model).active_elements.sample(2) }
  let(:subject_text) { ["A subject"] }
  let(:mesh) { ["A mesh"] }
  let(:add_info) { ["Some additional information"] }
  let(:doi) { "10.1521/soco.23.1.118.59197" }

  let(:advisor) { ["advisor"] }
  let(:publisher) { ["publisher1", "publisher2"] }
  let(:repository_space_options) { HykuAddons::RepositorySpaceService.new(model: model).active_elements.first }
  let(:source_data) { ["source 1", "Source 2"] }
  let(:journal_frequency) { "journal_frequency" }
  let(:funding_description) { ["Funding descrption 1", "Funding descrption 2"] }
  let(:citation) { ["citation1", "citation2"] }
  let(:table_of_contents) { "table_of_contents" }
  let(:references) { ["references1", "references2"] }
  let(:extent) { "extent" }
  let(:medium) { ["medium1", "medium2"] }
  let(:library_of_congress_classification) { ["1234", "5678"] }
  let(:committee_member) { ["Commitee member 1", "Commitee member 2"] }
  let(:time) { "time" }
  let(:part_of) { ["part_of123", "part_of456"] }
  let(:rights_statement_options) { HykuAddons::RightsStatementService.new(model: model).active_elements.sample(1) }
  let(:qualification_subject_text) { ["Qualification statement text 1", "Qualification statement text 2"] }
  let(:qualification_grantor) { "qualification_grantor" }
  let(:qualification_level_options) { HykuAddons::QualificationLevelService.new(model: model).active_elements.sample(1) }
  let(:qualification_name_options) { HykuAddons::QualificationNameService.new(model: model).active_elements.sample(1) }
  let(:is_format_of) { ["format_of123", "format_of456"] }

  before do
    Sipity::WorkflowAction.create!(name: "submit", workflow: workflow)
    Hyrax::PermissionTemplateAccess.create!(permission_options)
    allow(Site).to receive(:instance).and_return(site)

    login_as user
    visit new_work_path
  end

  context "when the form is filled out" do
    before do
      click_link "Descriptions"
      click_on "Additional fields"

      # Primary fields
      fill_in_text_field(:title, title)
      fill_in_multiple_text_fields(:alt_title, alt_title)
      fill_in_cloneable(:creator, creator)
      fill_in_textarea(:abstract, abstract)
      fill_in_date(:date_published, date_published)
      fill_in_text_field(:date_published_text, date_published_text)
      fill_in_select(:resource_type, resource_type.map { |h| h["label"] }.first)
      fill_in_multiple_selects(:license, license_options.map { |h| h["label"] })
      fill_in_multiple_text_fields(:place_of_publication, place_of_publication)
      fill_in_multiple_selects(:language, language_options.map { |h| h["label"] })
      fill_in_multiple_text_fields(:subject_text, subject_text)
      fill_in_multiple_text_fields(:mesh, mesh)
      fill_in_textarea(:add_info, add_info)
      fill_in_text_field(:doi, doi)

      # Additional fields
      fill_in_text_field(:advisor, advisor)
      fill_in_multiple_text_fields(:publisher, publisher)
      fill_in_select(:repository_space, repository_space_options["label"])
      fill_in_multiple_text_fields(:source, source_data)
      fill_in_text_field(:journal_frequency, journal_frequency)
      fill_in_multiple_text_fields(:funding_description, funding_description)
      fill_in_multiple_text_fields(:citation, citation)
      fill_in_textarea(:table_of_contents, table_of_contents)
      fill_in_multiple_text_fields(:references, references)
      fill_in_text_field(:extent, extent)
      fill_in_multiple_text_fields(:medium, medium)
      fill_in_multiple_text_fields(:library_of_congress_classification, library_of_congress_classification)
      fill_in_multiple_text_fields(:committee_member, committee_member)
      fill_in_text_field(:time, time)
      fill_in_multiple_text_fields(:part_of, part_of)
      fill_in_select(:rights_statement, rights_statement_options.first["label"])
      fill_in_multiple_text_fields(:qualification_subject_text, qualification_subject_text)
      fill_in_text_field(:qualification_grantor, qualification_grantor)
      fill_in_select(:qualification_level, qualification_level_options.map { |h| h["label"] }.first)
      fill_in_select(:qualification_name, qualification_name_options.map { |h| h["label"] }.first)
      fill_in_multiple_text_fields(:is_format_of, is_format_of)
    end

    describe "submitting the form" do
      before do
        add_visibility
        add_agreement
        submit
      end

      it "redirects to the work show page" do
        aggregate_failures "testing the saved data" do
          # Ensure the basic data is being prenented and we're on the right page
          expect(page).to have_selector("h1", text: work_type.titleize, wait: 20)
          expect(page).to have_selector("h2", text: title, wait: 20)
          expect(page).to have_selector("span", text: "Public")
          expect(page).to have_content("Your files are being processed by Hyku in the background.")

          expect(page).to have_content(resource_type.map { |h| h["id"] }.first)
          alt_title.each { |at| expect(page).to have_content(at) }
          expect(page).to have_content("#{creator.first.dig(:creator_family_name)}, #{creator.first.dig(:creator_given_name)}")
          expect(page).to have_content(normalize_date(date_published).first)
          expect(page).to have_content(doi)

          expect(work.title).to eq([title])
          expect(work.alt_title).to eq(alt_title)
          expect(work.creator).to eq([creator.to_json])
          expect(work.abstract).to eq(abstract)
          expect(work.date_published).to eq(normalize_date(date_published).first)
          expect(work.date_published_text).to eq(date_published_text)
          expect(work.resource_type).to eq(resource_type.map { |h| h["id"] })
          expect(work.license).to eq(license_options.map { |h| h["id"] })
          expect(work.language).to eq(language_options.map { |h| h["id"] })
          expect(work.subject_text).to eq(subject_text)
          expect(work.mesh).to eq(mesh)
          expect(work.add_info).to eq(add_info)
          expect(work.doi).to eq(doi)

          expect(work.advisor).to eq(advisor)
          expect(work.publisher).to eq(publisher)
          expect(work.repository_space).to eq(repository_space_options["id"])
          expect(work.source).to eq(source_data)
          expect(work.journal_frequency).to eq(journal_frequency)
          expect(work.funding_description).to eq(funding_description)
          expect(work.citation).to eq(citation)
          expect(work.table_of_contents).to eq(table_of_contents)
          expect(work.references).to eq(references)
          expect(work.extent).to eq(extent)
          expect(work.medium).to eq(medium)
          expect(work.library_of_congress_classification).to eq(library_of_congress_classification)
          expect(work.committee_member).to eq(committee_member)
          expect(work.time).to eq(time)
          expect(work.part_of).to eq(part_of)
          # Rights statement is always saved as a multiple field
          expect(work.rights_statement).to eq([rights_statement_options.first["id"]])
          expect(work.qualification_subject_text).to eq(qualification_subject_text)
          expect(work.qualification_grantor).to eq(qualification_grantor)
          expect(work.qualification_level).to eq(qualification_level_options.map { |h| h["id"] }.first)
          expect(work.qualification_level).to eq(qualification_level_options.map { |h| h["id"] }.first)
          expect(work.qualification_name).to eq(qualification_name_options.map { |h| h["id"] }.first)
          expect(work.is_format_of).to eq(is_format_of)
        end
      end
    end
  end
end
