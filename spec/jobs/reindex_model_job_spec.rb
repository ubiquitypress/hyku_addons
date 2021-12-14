# frozen_string_literal: true

RSpec.describe HykuAddons::ReindexModelJob, type: :job do
  let(:account) { create(:account, cname: cname) }
  let(:work) { create(:work, doi: [], visibility: "open") }
  let(:private_work) { create(:work, title: ["private work"], doi: [], visibility: "restricted") }
  let(:pending_review_work) { create(:work, title: ["pending_review work"], doi: [], visibility: "open") }
  let(:prefix) { "10.1234" }
  let(:cname) { "123abc" }
  let(:response_body) { File.read(HykuAddons::Engine.root.join("spec", "fixtures", "doi", "mint_doi_return_body.json")) }
  let(:options) { { cname_doi_mint: [account.cname], use_work_ids: [work.id] } }

  let(:random_id) { SecureRandom.random_number(1_000_000) }
  let(:workflow) { instance_double(Sipity::Workflow, id: random_id, name: "testing", permission_template: permission_template) }
  let(:sipity_workflow_action) { instance_double(Sipity::WorkflowAction, id: random_id, name: "show", workflow_id: random_id) }
  let(:permission_template) { instance_double(Hyrax::PermissionTemplate, id: random_id) }
  let(:sipity_workflow_state) { instance_double(Sipity::WorkflowState, id: random_id, workflow: workflow, name: "deposited") }
  let(:object) { OpenStruct.new(to_sipity_entity: sipity_entity, workflow_state_name: "deposited") }
  let(:sipity_entity) { instance_double(Sipity::Entity, proxy_for_global_id: gid, workflow_id: workflow.id, workflow_state: sipity_workflow_state) }

  before do
    Hyrax::DOI::DataCiteRegistrar.username = "username"
    Hyrax::DOI::DataCiteRegistrar.password = "password"
    Hyrax::DOI::DataCiteRegistrar.prefix = prefix
    Hyrax::DOI::DataCiteRegistrar.mode = :test

    stub_request(:post, URI.join(Hyrax::DOI::DataCiteClient::TEST_BASE_URL, "dois"))
      .with(body: "{\"data\":{\"type\":\"dois\",\"attributes\":{\"prefix\":\"#{prefix}\"}}}",
            headers: { "Content-Type" => "application/vnd.api+json" },
            basic_auth: ["username", "password"])
      .to_return(status: 200, body: response_body)

    allow(Apartment::Tenant).to receive(:switch!).with(account.tenant) do |&block|
      block&.call
    end

    Apartment::Tenant.switch!(account.tenant) do
      work
      private_work
      pending_review_work
    end
  end

  context "mint doi" do
    let(:gid) { "gid://hyku/#{work.class}/#{work.id}" }

    it "when work visibility is public & doi is not present" do
      allow(Sipity::Entity).to receive(:find_by) { object }
      described_class.perform_now(work.class.to_s, account.cname, limit: 1, options: options)
      expect(work.reload.doi_status_when_public).to eq "findable"
    end
  end

  context "skip doi minting" do
    let(:gid) { "gid://hyku/#{pending_review_work.class}/#{pending_review_work.id}" }

    it "when work is private" do
      options[:use_work_ids] = [private_work.id]
      described_class.perform_now(private_work.class.to_s, account.cname, limit: 1, options: options)
      expect(private_work.reload.doi_status_when_public).to be_nil
    end

    it "when work is pending_review" do
      object.workflow_state_name = "pending_review"
      allow(Sipity::Entity).to receive(:find_by) { object }
      options[:use_work_ids] = [pending_review_work.id]

      described_class.perform_now(pending_review_work.class.to_s, account.cname, limit: 1, options: options)
      expect(pending_review_work.reload.doi_status_when_public).to be_nil
    end
  end
end
