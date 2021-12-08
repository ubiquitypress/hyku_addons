# frozen_string_literal: true

RSpec.describe HykuAddons::ReindexModelJob, type: :job do
  let(:account) { create(:account, cname: cname) }
  let(:work) { create(:work, doi: []) }
  let(:prefix) { "10.1234" }
  let(:cname) { "123abc" }
  let(:response_body) { File.read(HykuAddons::Engine.root.join("spec", "fixtures", "doi", "mint_doi_return_body.json")) }
  let(:options) { { cname_doi_mint: [account.cname], use_work_ids: [work.id] } }

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

    Apartment::Tenant.switch!(account.tenant) { work }
  end

  it "sets doi_status_when_public to findable" do
    described_class.perform_now(work.class.to_s, account.cname, limit: 1, options: options)
    expect(work.reload.doi_status_when_public).to eq "findable"
  end
end
