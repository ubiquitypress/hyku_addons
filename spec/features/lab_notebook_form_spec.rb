# frozen_string_literal: true

require HykuAddons::Engine.root.join("spec", "support", "fill_in_fields.rb").to_s
require HykuAddons::Engine.root.join("spec", "support", "work_form_helpers.rb").to_s

RSpec.feature "Create a UbiquityTemplateWork", js: true, slow: true do
  let(:work_type) { "ubiquity_template_work" }
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
  # The order of the items in each hash must match the order of the fields in the work form
  let(:resource_type) { HykuAddons::ResourceTypesService.new(model: model).active_elements.sample(1) }
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
  let(:abstract) { "This is the abstract text" }
  let(:time) { "time" }
  let(:subject_options) { HykuAddons::SubjectService.new(model: model).active_elements.sample(2) }
  let(:keyword) { ["keyword1", "keyword2"] }
  let(:doi) { "10.1521/soco.23.1.118.59197" }
  let(:related_publication_citaion) { ["citation1", "citation2"] }
  let(:related_url) { ["http://test.com", "https://www.test123.com"] }
  let(:language_options) { HykuAddons::LanguageService.new(model: model).active_elements.sample(2) }
  let(:license_options) { HykuAddons::LicenseService.new(model: model).active_elements.sample(2) }
  let(:rights_holder) { ["Holder1", "Holder2"] }
  let(:rights_statement_options) { HykuAddons::RightsStatementService.new(model: model).active_elements.sample(1) }
  let(:add_info) { "Some additional information" }


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

      # Required fields
      fill_in_text_field(:title, title)
      fill_in_select(:resource_type, resource_type.map { |h| h["label"] }.first)
      fill_in_cloneable(:creator, creator)



      # Additional fields
      fill_in_textarea(:abstract, abstract)
      fill_in_text_field(:time, time)
      fill_in_multiple_selects(:subject, subject_options.map { |h| h["label"] })
      fill_in_multiple_text_fields(:keyword, keyword)
      fill_in_text_field(:doi, doi)
      fill_in_multiple_text_fields(:related_publication_citation, related_publication_citation)
      fill_in_multiple_text_fields(:related_url, related_url)
      fill_in_multiple_selects(:language, language_options.map { |h| h["label"] })
      fill_in_multiple_selects(:license, license_options.map { |h| h["label"] })
      fill_in_multiple_text_fields(:rights_holder, rights_holder)
      fill_in_select(:rights_statement, rights_statement_options.map { |h| h["label"] }.first)
      fill_in_textarea(:add_info, add_info)
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
          expect(page).to have_content(alt_class.map { |h| h["id"] }.first)
          alt_title.each { |at| expect(page).to have_content(at) }
          expect(page).to have_content("#{creator.first.dig(:creator_family_name)}, #{creator.first.dig(:creator_given_name)}")
          expect(page).to have_content("#{contributor.first.dig(:contributor_family_name)}, #{contributor.first.dig(:contributor_given_name)}")
          %i[published accepted submitted].each { |d| expect(page).to have_content(normalize_date(send("date_#{d}".to_sym)).first) }
          duration.each { |at| expect(page).to have_content(at) }
          description.each { |at| expect(page).to have_content(at) }
          expect(page).to have_content("https://doi.org/#{doi}")

          expect(work.title).to eq([title])
          expect(work.resource_type).to eq(resource_type.map { |h| h["id"] })
          expect(work.creator).to eq([creator.to_json.gsub(organisation_option["label"], organisation_option["id"])])
          expect(work.abstract).to eq(abstract)
          expect(work.time).to eq(time)
          expect(work.subject).to eq(subject_options.map { |h| h["id"] })
          expect(work.keyword).to eq(keyword)
          expect(work.doi).to eq([doi])
          expect(work.related_publication_citaion).to eq(related_publication_citaion)
          expect(work.related_url).to eq(related_url)
          expect(work.language).to eq(language_options.map { |h| h["id"] })
          expect(work.license).to eq(license_options.map { |h| h["id"] })
          expect(work.rights_holder).to eq(rights_holder)
          expect(work.rights_statement).to eq(rights_statement_options.map { |h| h["id"] })
          expect(work.add_info).to eq(add_info)
        end
      end
    end
  end
end