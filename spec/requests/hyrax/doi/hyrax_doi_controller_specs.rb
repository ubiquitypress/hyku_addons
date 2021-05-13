# frozen_string_literal: true

require "spec_helper"

RSpec.describe Hyrax::DOI::HyraxDOIController, type: :request, multitenant: true, clean_repo: true do
  let(:user) { create(:user, email: 'user@pacificu.edu') }
  let!(:account) { create(:account) }

  let(:admin_set_id) { AdminSet.find_or_create_default_admin_set_id }
  let(:permission_template) { Hyrax::PermissionTemplate.find_or_create_by!(source_id: admin_set_id) }
  let(:workflow) do
    Sipity::Workflow.create!(
      active: true,
      name: 'test-workflow',
      permission_template: permission_template
    )
  end

  let(:path) { "/doi/autofill.json" }
  let(:params) {  { curation_concern: "generic_work", doi: doi } }
  let(:doi_url) { [path, params.to_query].join("?") }

  before do
    # Required to set deposit permissions for the user or the request will see a Not Authorized exception
    Sipity::WorkflowAction.create!(name: 'submit', workflow: workflow)
    Hyrax::PermissionTemplateAccess.create!(
      permission_template_id: permission_template.id,
      agent_type: 'user',
      agent_id: user.user_key,
      access: 'deposit'
    )

    login_as user

    # We need to be able to make requests for the DOIs entered
    WebMock.disable!

    Site.update(account: account)
    allow(Apartment::Tenant).to receive(:switch).with(account.tenant) do |&block|
      block.call
    end
    host! account.cname
  end

  after do
    WebMock.enable!
  end

  describe "#autofill" do
    before do
      get doi_url
    end

    context "when the DOI is invalid" do
      let(:doi) { "10.12312312/23411451345" }

      it "returns the error message" do
        get doi_url
        expect(response).not_to be_successful
      end
    end

    context "when the DOI is valid" do
      let(:doi) { "10.5334/bbc" }

      it "returns the JSON response" do
        get doi_url
        expect(response).to be_successful
      end
    end
  end
end
