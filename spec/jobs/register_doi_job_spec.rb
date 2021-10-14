# frozen_string_literal: true
require 'rails_helper'

# Copied over from hyrax-doi as a sanity check that things are still working
RSpec.describe Hyrax::DOI::RegisterDOIJob, type: :job do
  let(:work) { create(:work, visibility: 'open', doi_status_when_public: 'findable') }
  let(:prefix) { "10.1234" }
  let(:suffix) { "abcdef" }
  let(:doi) { "#{prefix}/#{suffix}" }
  let(:response_body) { File.read(HykuAddons::Engine.root.join("spec", "fixtures", "doi", "mint_doi_return_body.json")) }

  before do
    Rails.application.routes.default_url_options[:host] = 'example.com'
    Hyrax.config.identifier_registrars = { datacite: Hyrax::DOI::DataCiteRegistrar }
    Hyrax::DOI::DataCiteRegistrar.mode = :test
    Hyrax::DOI::DataCiteRegistrar.prefix = prefix
    Hyrax::DOI::DataCiteRegistrar.username = 'username'
    Hyrax::DOI::DataCiteRegistrar.password = 'password'

    stub_request(:post, URI.join(Hyrax::DOI::DataCiteClient::TEST_BASE_URL, "dois"))
      .with(headers: { "Content-Type" => "application/vnd.api+json" },
            basic_auth: ['username', 'password'],
            body: "{\"data\":{\"type\":\"dois\",\"attributes\":{\"prefix\":\"#{prefix}\"}}}")
      .to_return(status: 201, body: response_body)

    stub_request(:put, URI.join(Hyrax::DOI::DataCiteClient::TEST_MDS_BASE_URL, "metadata/#{doi}"))
      .with(headers: { 'Content-Type': 'application/xml;charset=UTF-8' },
            basic_auth: ['username', 'password'])
      .to_return(status: 201, body: "OK (#{doi})")

    stub_request(:put, URI.join(Hyrax::DOI::DataCiteClient::TEST_MDS_BASE_URL, "doi/#{doi}"))
      .with(headers: { 'Content-Type': 'text/plain;charset=UTF-8' },
            basic_auth: ['username', 'password'])
      .to_return(status: 201, body: "")
  end

  it 'mints a DOI' do
    expect { described_class.perform_now(work, registrar: work.doi_registrar.presence, registrar_opts: work.doi_registrar_opts) }
      .to change { work.doi }
      .to eq [doi]
  end
end
