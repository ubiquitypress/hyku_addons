# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::Orcid::OrcidWorkService do
  let(:sync_preference) { "sync_all" }
  let(:service) { described_class.new(work, orcid_identity) }
  let(:user) { create(:user, orcid_identity: orcid_identity) }
  let(:orcid_identity) { create(:orcid_identity, work_sync_preference: sync_preference) }
  let(:work) { create(:work, user: user, **work_attributes) }
  let(:work_attributes) do
    {
      "title" => ["Moomin"],
      "creator" => [
        [{
          "creator_given_name" => "Smith",
          "creator_family_name" => "John",
          "creator_name_type" => "Personal",
          "creator_orcid" => orcid_id
        }].to_json
      ]
    }
  end
  let(:orcid_id) { user.orcid_identity.orcid_id }
  let(:api_version) { Hyrax::Orcid::UrlHelper::ORCID_API_VERSION }
  let(:input) { work.attributes.merge(has_model: work.has_model.first).to_json }
  let(:meta) { Bolognese::Readers::GenericWorkReader.new(input: input, from: "work") }
  let(:type) { "other" }
  let(:put_code) { nil }
  let(:xml) { meta.orcid_xml(type, put_code) }

  describe "#publish" do
    let(:faraday_response) { instance_double(Faraday::Response, body: "", headers: response_headers, success?: true) }
    let(:put_code) { "123456" }
    let(:response_headers) do
      { "location" => "http://api.sandbox.orcid.org/#{api_version}/#{orcid_id}/work/#{put_code}" }
    end

    context "when the work has not been published to ORCID yet" do
      # Even though we have the put_code set, not passing it in here, will remove it from the XML output
      let(:xml) { meta.orcid_xml(type, nil) }
      let(:url) { "https://api.sandbox.orcid.org/#{api_version}/#{orcid_id}/work" }

      before do
        allow(Faraday).to receive(:send).and_return(faraday_response)

        service.perform
      end

      it "calls Faraday" do
        expect(Faraday).to have_received(:send).with(:post, url, xml, service.send(:headers))
      end

      it "adds the orcid_work association" do
        orcid_work = orcid_identity.orcid_works.first

        expect(orcid_work).to be_present
        expect(orcid_work.work_uuid).to eq work.id
        expect(orcid_work.put_code).to eq put_code
      end
    end

    context "when the work has been published to ORCID" do
      let(:url) { "https://api.sandbox.orcid.org/#{api_version}/#{orcid_id}/work/#{put_code}" }
      let(:orcid_work) { create(:orcid_work, orcid_identity: orcid_identity, work_uuid: work.id, put_code: put_code) }

      before do
        allow(Faraday).to receive(:send).and_return(faraday_response)

        # By adding the orcid work to the identity, we ensure that a PUT update request is performed
        orcid_identity.orcid_works << orcid_work

        service.perform
      end

      it "calls Faraday" do
        expect(Faraday).to have_received(:send).with(:put, url, xml, service.send(:headers))
      end
    end
  end

  describe "#request_url" do
    context "when the work was published" do
      let(:put_code) { "123456" }
      let(:orcid_work) { create(:orcid_work, orcid_identity: orcid_identity, work_uuid: work.id, put_code: put_code) }
      let(:url) { "https://api.sandbox.orcid.org/#{api_version}/#{orcid_id}/work/#{put_code}" }

      before do
        orcid_identity.orcid_works << orcid_work
      end

      it { expect(service.send(:request_url)).to eq url }
    end

    context "when the work was not published" do
      let(:url) { "https://api.sandbox.orcid.org/#{api_version}/#{orcid_id}/work" }

      it { expect(service.send(:request_url)).to eq url }
    end
  end

  describe "#xml" do
    it { expect(service.send(:xml)).to be_a(String) }
  end

  describe "#previously_uploaded?" do
    context "when the work was published" do
      let(:put_code) { "123456" }
      let(:orcid_work) { create(:orcid_work, orcid_identity: orcid_identity, work_uuid: work.id, put_code: put_code) }

      before do
        orcid_identity.orcid_works << orcid_work
      end

      it { expect(service.send(:previously_uploaded?)).to be true }
    end

    context "when the work was not published" do
      it { expect(service.send(:previously_uploaded?)).to be false }
    end
  end

  describe "#request_method" do
    context "when the work was published" do
      let(:put_code) { "123456" }
      let(:orcid_work) { create(:orcid_work, orcid_identity: orcid_identity, work_uuid: work.id, put_code: put_code) }

      before do
        orcid_identity.orcid_works << orcid_work
      end

      it { expect(service.send(:request_method)).to be :put }
    end

    context "when the work was not published" do
      it { expect(service.send(:request_method)).to be :post }
    end
  end

  describe "#headers" do
    let(:headers) { service.send(:headers) }

    it { expect(headers).to be_a(Hash) }
    it { expect(headers.dig("authorization")).to eq "Bearer #{orcid_identity.access_token}" }
  end
end

