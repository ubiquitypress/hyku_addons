# frozen_string_literal: true

require "spec_helper"

require HykuAddons::Engine.root.join("spec", "support", "fill_in_fields.rb").to_s
require HykuAddons::Engine.root.join("spec", "support", "work_form_helpers.rb").to_s

RSpec.feature "Create a UnaArchivalItem", js: true, slow: true do
  let(:work_type) { "una_archival_item" }
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

  let(:title) { "UNA Archival Item" }
  # The organisation option changes depending on the local, so we need to use this to ensure we select the right one
  let(:organisation_option) { HykuAddons::NameTypeService.new(model: model).active_elements.last }
  # The order of the items in each hash must match the order of the fields in the work form
  let(:creator) do
    [
      {
        creator_name_type: "Personal",
        creator_family_name: "Johnny",
        creator_given_name: "Smithy",
        creator_middle_name: "J.",
        creator_suffix: "Mr",
        creator_orcid: "0000-0000-1111-2222",
        # This is a hidden field set in the form, but we want to be able to check its value is set
        creator_profile_visibility: User::PROFILE_VISIBILITY[:closed],
        creator_institutional_relationship: "Research associate",
        creator_institutional_email: "test@test.com",
        creator_isni: "56273930281"
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
  let(:resource_type) { HykuAddons::ResourceTypesService.new(model: model).active_elements.sample(1) }
  let(:abstract) { "This is the abstract text" }
  let(:license_options) { HykuAddons::LicenseService.new(model: model).active_elements.sample(2) }
  let(:publisher) { ["publisher1", "publisher2"] }
  let(:keyword) { ["keyword1", "keyword2"] }
  let(:doi) { "10.1521/soco.23.1.118.59197" }
  let(:contributor) do
    [
      {
        contributor_name_type: "Personal",
        contributor_family_name: "Smithy",
        contributor_given_name: "Johnny",
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
  let(:language_options) { HykuAddons::LanguageService.new(model: model).active_elements.sample(2) }
  let(:date_published) { { year: "2020", month: "02", day: "02" } }
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
  let(:alternate_identifier) do
    [
      { alternate_identifier: "123456", alternate_identifier_type: "Alt Ident." },
      { alternate_identifier: "098765", alternate_identifier_type: "Alt Ident. 2" }
    ].sample(1)
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
  let(:add_info) { "Some additional information" }
  let(:source_data) { ["source 1", "Source 2"] }
  let(:related_url) { ["http://test.com", "https://www.test123.com"] }

  before do
    Sipity::WorkflowAction.create!(name: "submit", workflow: workflow)
    Hyrax::PermissionTemplateAccess.create!(permission_options)

    stub_request(:get, "http://api.crossref.org/funders?query=A%20funder")
      .with(headers: headers)
      .to_return(status: 200, body: "", headers: {})

    stub_request(:get, "http://api.crossref.org/funders?query=Another%20funder")
      .with(headers: headers)
      .to_return(status: 200, body: "", headers: {})

    login_as user
    visit new_work_path
  end

  context "when the form is filled out" do
    before do
      click_link "Descriptions"
      click_on "Additional fields"

      fill_in_text_field(:title, title)
      fill_in_text_field(:doi, doi)
      fill_in_cloneable(:creator, creator)
      fill_in_select(:resource_type, resource_type.map { |h| h["label"] }.first)
      fill_in_textarea(:abstract, abstract)
      fill_in_select(:license, license_options.map { |h| h["label"] }&.first)
      fill_in_text_field(:publisher, publisher)
      fill_in_multiple_text_fields(:keyword, keyword)
      fill_in_cloneable(:contributor, contributor)
      fill_in_select(:language, language_options.map { |h| h["label"] }&.first)
      fill_in_date(:date_published, date_published)
      fill_in_cloneable(:funder, funder)
      fill_in_textarea(:add_info, add_info)
      fill_in_cloneable(:alternate_identifier, alternate_identifier)
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
          expect(page).to have_content("#{creator.first.dig(:creator_family_name)}, #{creator.first.dig(:creator_given_name)}")
          expect(page).to have_content("#{contributor.first.dig(:contributor_family_name)}, #{contributor.first.dig(:contributor_given_name)}")
          expect(page).to have_content(normalize_date(date_published).first)
          expect(page).to have_content("https://doi.org/#{doi}")
          expect(work.title).to eq([title])
          expect(work.doi).to eq([doi])
          expect(work.creator).to eq([creator.to_json.gsub(organisation_option["label"], organisation_option["id"])])
          expect(work.resource_type).to eq(resource_type.map { |h| h["id"] })
          expect(work.abstract).to eq(abstract)
          expect(work.keyword).to eq(keyword)
          expect(work.contributor).to eq([contributor.to_json.gsub(organisation_option["label"], organisation_option["id"])])
          expect(work.funder).to eq([funder.to_json])
          expect(work.add_info).to eq(add_info)
          expect(work.alternate_identifier).to eq([alternate_identifier.to_json])
        end
      end
    end
  end
end
