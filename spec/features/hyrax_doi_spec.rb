# frozen_string_literal: true

# FIXME: These tests don't seem to work because of the following error:
#
# Apartment::Tenant received :switch with unexpected arguments
#   expected: ("01f8b714-8373-4ccc-b6c1-7ba9e1522e47")
#        got: ("public")
#  Please stub a default value first if message might be received with other args as well.
#
# We put in the time trying just about everything we can think of to get them to work, but either do not understand
# some fundamental setup that is required, or have missed something important. Either way, we cannot be sure that the
# DOIs mint properly until these tests pass.

require "rails_helper"

RSpec.describe "Minting a DOI for an existing work", type: :feature, js: true, multitenant: true do
  let(:user) { create(:user) }
  let(:admin) { create(:admin) }
  let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
  let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
  let(:workflow) do
    Sipity::Workflow.create!(
      active: true,
      name: "test-workflow",
      permission_template: permission_template,
      allows_access_grant: true
    )
  end

  let(:work) do
    attributes = {
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
    create(:work, attributes)
  end

  let(:prefix) { "10.23716" }
  let(:account) do
    account = create(:account)
    account.create_datacite_endpoint(
      mode: :test,
      prefix: prefix,
      username: "VJKA.JCRXZG-LOCAL",
      password: "password"
    )
    account.save
    account
  end
  let!(:site) { Site.create(account: account) }
  let(:routes) { Rails.application.routes.url_helpers }

  before do
    allow(Flipflop).to receive(:enabled?).and_call_original
    allow(Flipflop).to receive(:enabled?).with(:doi_minting).and_return(true)

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

    Capybara.default_host = "http://#{account.cname}"
    default_url_options[:host] = Capybara.default_host

    login_as admin
  end

  describe "when the user edits a work without a minted DOI" do
    before do
      allow(Apartment::Tenant).to receive(:switch).with(account.tenant) do |&block|
        block.call
      end
      account.switch!

      visit "/concern/#{work.class.name.underscore.to_s.pluralize}/#{work.id}/edit"
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
      let(:doi) { "#{prefix}/kgkc-nn31" }

      let(:response_fixture) { File.read Rails.root.join("..", "fixtures", "datacite", "put_metadata.xml") }
      let(:common_headers) do
        {
          "Accept": "*/*",
          "Accept-Encoding": "gzip;q=1.0,deflate;q=0.6,identity;q=0.3",
          "Authorization": "Basic VkpLQS5KQ1JYWkctTE9DQUw6cGFzc3dvcmQ=",
          "User-Agent": "Faraday v0.17.4"
        }
      end
      let(:json_headers) do
        common_headers.merge("Content-Type": "application/vnd.api+json")
      end
      let(:xml_headers) do
        common_headers.merge("Content-Type": "application/xml;charset=UTF-8")
      end
      let(:text_headers) do
        common_headers.merge("Content-Type": "text/plain;charset=UTF-8")
      end

      # The initial request to create_draft_doi
      before do
        stub_request(:post, "https://api.test.datacite.org/dois")
          .with(body: { "data": { "type": "dois", "attributes": { "prefix": prefix } } }.to_json, headers: json_headers)
          .to_return(status: 201, body: { "data": { "id": doi, "type": "dois", "attributes": {} } }.to_json, headers: {})

        # Send the work data to datacite
        stub_request(:put, "https://mds.test.datacite.org/metadata/#{doi}")
          .with(body: response_fixture, headers: xml_headers)
          .to_return(status: 201, body: "", headers: {})

        # Register the URL
        stub_request(:put, "https://mds.test.datacite.org/doi/#{doi}")
          .with(body: "doi=#{doi}\nurl=http://#{account.cname}/concern/generic_works/#{work.id}", headers: text_headers)
          .to_return(status: 201, body: "", headers: {})
      end

      xit "mints a DOI" do
        perform_enqueued_jobs do
          choose "Findable"
          choose "generic_work_visibility_open"
          check "agreement"

          find("a[role=tab]", text: "Description").click
          fill_in("Title", with: new_title)
          find("input[type=submit]").click

          # Ensure we end up on the right page
          expect(page).to have_selector("h1", text: "Work", wait: 10)
          expect(page).to have_selector("h2", text: new_title)
          expect(page).to have_selector("a", text: "https://doi.org/#{doi}")
        end
      end
    end
  end
end
