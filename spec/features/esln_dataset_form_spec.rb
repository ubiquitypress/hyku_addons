# frozen_string_literal: true

require HykuAddons::Engine.root.join("spec", "support", "fill_in_fields.rb").to_s
require HykuAddons::Engine.root.join("spec", "support", "work_form_helpers.rb").to_s

RSpec.feature "Create a EslnDataset", js: true, slow: true do
  let(:work_type) { "esln_dataset" }
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
        creator_orcid: "0000-0000-1111-2222",
        creator_institutional_relationship: "Research associate",
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
  let(:contributor) do
    [
      {
        contributor_family_name: "Smithy",
        contributor_name_type: "Personal",
        contributor_given_name: "Johnny",
        contributor_orcid: "0000-1111-2222-3333",
        contributor_institutional_relationship: "Staff member",
        contributor_isni: "1234567890",
        contributor_role: ["Actor"]
      },
      {
        contributor_name_type: "Organisational",
        contributor_organization_name: "A Test Company Name",
        contributor_ror: "ror.org/1234",
        contributor_grid: "grid.com/1234",
        contributor_wikidata: "wikidata.org/1234",
        contributor_isni: "1234567890",
        contributor_role: ["Actor"]
      }
    ]
  end

  let(:resource_type) { HykuAddons::ResourceTypesService.new(model: model).active_elements.sample(1) }
  let(:date_published) { { year: "2020", month: "02", day: "02" } }
  let(:keyword) { ["keyword1", "keyword2"] }
  let(:license_options) { HykuAddons::LicenseService.new(model: model).active_elements.sample(2) }
  let(:subject_options) { HykuAddons::SubjectService.new(model: model).active_elements.sample(2) }
  let(:language_options) { HykuAddons::LanguageService.new(model: model).active_elements.sample(2) }
  let(:abstract) { "This is the abstract text" }
  let(:institution_options) { HykuAddons::InstitutionService.new(model: model).active_elements.sample(2) }
  let(:org_unit) { ["Unit1", "Unit2"] }
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

  let(:time) { "time" }
  let(:media) { ["Audio", "Video"] }

  let(:version_number) { ["3"] }
  let(:extent) { "extent" }
  let(:longitude) { "0.124356" }
  let(:latitude) { "1.345678" }
  let(:location) { "london" }

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
      fill_in_multiple_text_fields(:alt_title, alt_title)
      fill_in_select(:resource_type, resource_type.map { |h| h["label"] }.first)
      fill_in_cloneable(:creator, creator)
      fill_in_date(:date_published, date_published)
      fill_in_cloneable(:contributor, contributor)

      # Additional fields
      fill_in_multiple_text_fields(:keyword, keyword)
      fill_in_multiple_selects(:license, license_options.map { |h| h["label"] })
      fill_in_multiple_selects(:subject, subject_options.map { |h| h["label"] })
      fill_in_multiple_selects(:language, language_options.map { |h| h["label"] })
      fill_in_textarea(:abstract, abstract)
      fill_in_multiple_selects(:institution, institution_options.map { |h| h["label"] })
      fill_in_multiple_text_fields(:org_unit, org_unit)

      fill_in_cloneable(:alternate_identifier, alternate_identifier)
      fill_in_cloneable(:related_identifier, related_identifier_label)
      fill_in_select(:refereed, refereed_options.map { |h| h["label"] }.first)
      fill_in_textarea(:add_info, add_info)

      fill_in_multiple_text_fields(:media, media)
      fill_in_text_field(:time, time)

      fill_in_text_field(:longitude, longitude)
      fill_in_text_field(:latitude, latitude)
      fill_in_text_field(:location, location)
      fill_in_text_field(:version_number, version_number)
      fill_in_text_field(:extent, extent)
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
          alt_title.each { |at| expect(page).to have_content(at) }
          expect(page).to have_content("#{creator.first.dig(:creator_family_name)}, #{creator.first.dig(:creator_given_name)}")
          expect(page).to have_content("#{contributor.first.dig(:contributor_family_name)}, #{contributor.first.dig(:contributor_given_name)}")
          %i[published].each { |d| expect(page).to have_content(normalize_date(send("date_#{d}".to_sym)).first) }
          expect(page).to have_content("https://doi.org/#{doi}")

          expect(work.title).to eq([title])
          expect(work.doi).to eq([doi])
          expect(work.resource_type).to eq(resource_type.map { |h| h["id"] })
          expect(work.date_published).to eq(normalize_date(date_published).first)
          # Cloneable fields use the label to select the option, but save the id to the work
          expect(work.creator).to eq([creator.to_json.gsub(organisation_option["label"], organisation_option["id"])])
          # expect(work.contributor).to eq([contributor.to_json.gsub(organisation_option["label"], organisation_option["id"])])
          expect(work.keyword).to eq(keyword)
          expect(work.license).to eq(license_options.map { |h| h["id"] })
          expect(work.subject).to eq(subject_options.map { |h| h["id"] })
          expect(work.language).to eq(language_options.map { |h| h["id"] })
          # expect(work.abstract).to eq(abstract)
          expect(work.institution).to eq(institution_options.map { |h| h["id"] })
          expect(work.org_unit).to eq(org_unit)
          expect(work.alternate_identifier.first).to eq(alternate_identifier.to_json)
          expect(work.related_identifier.first).to eq(related_identifier_id.to_json)
          expect(work.refereed).to eq(refereed_options.map { |h| h["id"] }.first)
          expect(work.add_info).to eq(add_info)

          expect(work.time).to eq(time)
          expect(work.media).to eq(media)

          expect(work.version_number).to eq(version_number)
          expect(work.longitude).to eq(longitude)
          expect(work.latitude).to eq(latitude)
          expect(work.location).to eq(location)
          expect(work.extent).to eq(extent)
        end
      end
    end
  end
end
