# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Minting a DOI for an existing work", multitenant: true, js: true do
  let(:user) { create(:user) }
  let(:attributes) do
    {
      title: ["Work title"],
      doi_status_when_public: nil,
      visibility: Hydra::AccessControls::AccessRight::VISIBILITY_TEXT_VALUE_PUBLIC,
      user: user,
      creator: [
        [{
          creator_name_type: "Personal",
          creator_given_name: "Johnny",
          creator_family_name: "Testison"
        }].to_json
      ],
      institution: ["University of Virginia"],
      resource_type: ["Blog post"]
    }
  end
  let!(:work) { create(:work, attributes) }
  let(:work_type) { work.class.name.underscore }

  let!(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
  let!(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
  let!(:workflow) do
    Sipity::Workflow.create!(
      active: true,
      name: "test-workflow",
      permission_template: permission_template
    )
  end

  let(:prefix) { "10.23716" }
  let(:cname) { "123456789" }

  let!(:account) { create(:account, cname: cname) }
  let!(:site) { Site.create(account: account) }

  before do
    allow(Site).to receive(:instance).and_return(site)
    allow(Flipflop).to receive(:enabled?).and_call_original
    allow(Flipflop).to receive(:enabled?).with(:doi_minting).and_return(true)

    account.build_datacite_endpoint(mode: "test", prefix: prefix, username: "VJKA.JCRXZG-LOCAL", password: "password")

    # NOTE: Because Hyrax::DOI is build for Hyrax and not a multitenant environment, the datacite_endpoint data is
    # assigned in class varibles when switch! is called in the engine. Because I can"t seem to mock those varibles
    # here and have the app see that, this is a hack to update them when they nil inside the class.
    Hyrax::DOI::DataCiteClient.class_eval do
      def username
        @username ||= Site.account.datacite_endpoint.username
      end

      def password
        @password ||= Site.account.datacite_endpoint.password
      end

      def prefix
        @prefix ||= Site.account.datacite_endpoint.prefix
      end

      def mode
        @mode ||= Site.account.datacite_endpoint.mode
      end
    end

    # NOTE: The default method from Bolognese isn"t sorting the identifiers, so they are returned in a random order,
    # which makes mocking the response impossible as WebMock thinks its a new request.
    Bolognese::DataciteUtils.class_eval do
      def insert_alternate_identifiers(xml)
        alternate_identifiers = Array.wrap(identifiers).select { |r| r["identifierType"] != "DOI" }.sort_by { |h| h["identifier"] }
        return xml unless alternate_identifiers.present?

        xml.alternateIdentifiers do
          Array.wrap(alternate_identifiers).each do |alternate_identifier|
            xml.alternateIdentifier(alternate_identifier["identifier"], "alternateIdentifierType": alternate_identifier["identifierType"])
          end
        end
      end
    end

    # NOTE: This monkeypatch is to get around an issue where by no matter what I try, the Rails routes are not having
    # their host set by the default_url_options command above. I don't like this either.
    Hyrax::DOI::DataCiteRegistrar.class_eval do
      def work_url(work)
        Rails.application.routes.url_helpers.polymorphic_url(work, host: Site.instance.account.cname)
      end
    end

    # Create a single action that can be taken
    Sipity::WorkflowAction.create!(name: "submit", workflow: workflow)

    # Grant the user access to deposit into the admin set.
    Hyrax::PermissionTemplateAccess.create!(
      permission_template_id: permission_template.id,
      agent_type: "user",
      agent_id: user.user_key,
      access: "deposit"
    )

    # Ensure that the _url methods have a host when creating XML data
    Capybara.default_host = "http://#{cname}"
    default_url_options[:host] = "http://#{cname}"

    login_as user
  end

  describe "when the user edits a work without a minted DOI" do
    before do
      visit "/concern/#{work_type.to_s.pluralize}/#{work.id}/edit"
    end

    it "Sets up the page correctly" do
      expect(page).to have_content "Edit Work"

      find("a[role=tab]", text: "DOI").click

      # have_field with nil value isn"t working properly here
      expect(find_field("DOI").value).to eq ""
      expect(find(:radio_button, "generic_work[doi_status_when_public]", checked: true).value).to eq ""
      expect(find(:radio_button, "generic_work[visibility]", checked: true).value).to eq "open"

      find("a[role=tab]", text: "Description").click
      expect(page).to have_field("Title", with: work.title.first)
    end

    context "when the user selects `findable`" do
      let(:new_title) { "New work title" }

      it "redirects the user to the works page" do
        fill_in_form(new_title)

        expect(page).to have_selector("h1", text: "Work", wait: 10)
        expect(page).to have_selector("h2", text: new_title)
      end

      it "enqueues a job to mint the DOI" do
        expect { fill_in_form(new_title) }.to have_enqueued_job(Hyrax::DOI::RegisterDOIJob).with(work.reload, registrar: "datacite", registrar_opts: {})
      end
    end
  end

  private

    def fill_in_form(title)
      choose "Findable"
      choose "generic_work_visibility_open"
      check "agreement"

      find("a[role=tab]", text: "Description").click
      fill_in("Title", with: title)
      find("input[type=submit]").click
    end
end
