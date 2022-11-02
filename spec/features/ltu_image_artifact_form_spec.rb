# frozen_string_literal: true

require HykuAddons::Engine.root.join("spec", "support", "fill_in_fields.rb").to_s
require HykuAddons::Engine.root.join("spec", "support", "work_form_helpers.rb").to_s

RSpec.feature "Create a LtuImageArtifact", js: true, slow: true do
  let(:work_type) { "ltu_image_artifact" }
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
  let(:alt_title) { ["Alt Title 1", "Alt Title 2"].sample(1) }
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
        creator_culture: "british",
        creator_date: "2022-10-20",
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

  let(:resource_type) { HykuAddons::ResourceTypesService.new(model: model).active_elements.sample(1) }
  let(:keyword) { ["keyword1", "keyword2"] }
  let(:license_options) { HykuAddons::LicenseService.new(model: model).active_elements.sample(2) }
  let(:abstract) { "This is the abstract text" }

  let(:add_info) { "Some additional information" }
  let(:extent) { "extent" }
  let(:location) { "london" }
  let(:official_link) { "http://test312.com" }

  let(:rights_holder) { ["Holder1", "Holder2"].sample(1) }
  let(:rights_statement_options) { HykuAddons::RightsStatementService.new(model: model).active_elements.sample(1) }
  let(:rights_statement_text) { "rights_statement_text" }
  let(:extent) { "extent" }
  let(:subject_text) { ["subject1", "subject2"] }
  let(:rights) { ["Rights1", "Rights2"] }
  let(:style_period_options) { HykuAddons::StylePeriodService.new(model: model).active_elements.sample(2) }

  before do
    Sipity::WorkflowAction.create!(name: "submit", workflow: workflow)
    Hyrax::PermissionTemplateAccess.create!(permission_options)
    allow(Flipflop).to receive(:enabled?).and_call_original
    allow(Flipflop).to receive(:enabled?).with(:doi_minting).and_return(false)

    login_as user
    visit new_work_path
  end

  context "when the form is filled out" do
    before do
      click_link "Descriptions"
      click_on "Additional fields"

      # Required fields
      fill_in_text_field(:title, title)
      fill_in_text_field(:alt_title, alt_title.first)
      fill_in_select(:resource_type, resource_type.map { |h| h["label"] }.first)
      fill_in_cloneable(:creator, creator)

      # Additional fields
      fill_in_multiple_text_fields(:keyword, keyword)
      fill_in_multiple_selects(:license, license_options.map { |h| h["label"] })
      fill_in_textarea(:abstract, abstract)

      fill_in_textarea(:add_info, add_info)
      fill_in_text_field(:location, location)
      fill_in_text_field(:extent, extent)
      fill_in_text_field(:official_link, official_link)
      fill_in_text_field(:rights_holder, rights_holder.first)

      fill_in_select(:rights_statement, rights_statement_options.map { |h| h["label"] }.first)
      fill_in_text_field(:rights_statement_text, rights_statement_text)

      fill_in_text_field(:extent, extent)
      fill_in_multiple_text_fields(:subject_text, subject_text)
      fill_in_multiple_text_fields(:rights, rights)
      fill_in_multiple_selects(:style_period, style_period_options.map { |h| h["label"] })
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
          # alt_title.each { |at| expect(page).to have_content(at) }
          expect(work.alt_title).to eq(alt_title)
          expect(page).to have_content("#{creator.first.dig(:creator_family_name)}, #{creator.first.dig(:creator_given_name)}")
          # %i[published].each { |d| expect(page).to have_content(normalize_date(send("date_#{d}".to_sym)).first) }

          expect(work.title).to eq([title])
          expect(work.resource_type).to eq(resource_type.map { |h| h["id"] })
          expect(work.official_link).to eq(official_link)
          # Cloneable fields use the label to select the option, but save the id to the work
          # expect(work.creator).to eq([creator.to_json.gsub(organisation_option["label"], organisation_option["id"])])
          expect(work.keyword).to eq(keyword)
          expect(work.license).to eq(license_options.map { |h| h["id"] })
          expect(work.abstract).to eq(abstract)
          expect(work.add_info).to eq(add_info)

          expect(work.extent).to eq(extent)
          expect(work.rights_holder).to eq(rights_holder)
          expect(work.rights).to eq(rights)
          # expect(work.rights_statement).to eq(rights_statement_options.map { |h| h["id"] })
          expect(work.rights_statement_text).to eq(rights_statement_text)

          expect(work.extent).to eq(extent)
          expect(work.subject_text).to eq(subject_text)
          expect(work.style_period).to eq(style_period_options.map { |h| h["id"] })
        end
      end
    end
  end
end
