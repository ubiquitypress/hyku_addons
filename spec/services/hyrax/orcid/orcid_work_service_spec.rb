# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::Orcid::OrcidWorkService do
  let(:sync_preference) { "sync_all" }
  let(:service) { described_class.new(work, orcid_identity) }
  let(:user) { create(:user, orcid_identity: orcid_identity) }
  let(:orcid_identity) { create(:orcid_identity, work_sync_preference: sync_preference) }
  let(:work) { create(:work, :public, user: user, **work_attributes) }
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
  let(:put_code) { "123456" }
  let(:xml) { meta.orcid_xml(type, put_code) }
  let(:orcid_work) { create(:orcid_work, orcid_identity: orcid_identity, work_uuid: work.id, put_code: put_code) }
  let(:faraday_response) { instance_double(Faraday::Response, body: "", headers: response_headers, success?: true) }
  let(:response_headers) { { "location" => url } }
  let(:url) { "https://api.sandbox.orcid.org/#{api_version}/#{orcid_id}/work/#{put_code}" }

  describe "#publish" do
    before do
      allow(Faraday).to receive(:send).and_return(faraday_response)
    end

    context "when the work has not been published to ORCID yet" do
      # Even though we have the put_code set, not passing it in here, will remove it from the XML output
      let(:xml) { meta.orcid_xml(type, nil) }
      let(:put_code) { "198765" }
      let(:url) { "https://api.sandbox.orcid.org/#{api_version}/#{orcid_id}/work" }
      let(:response_headers) do
        { "location" => "https://api.sandbox.orcid.org/#{api_version}/#{orcid_id}/work/#{put_code}"  }
      end

      it "calls Faraday" do
        service.publish

        expect(Faraday).to have_received(:send).with(:post, url, xml, service.send(:headers))
      end

      it "adds the orcid_work association" do
        service.publish

        identity_orcid_work = orcid_identity.orcid_works.first

        expect(identity_orcid_work).to be_present
        expect(identity_orcid_work.work_uuid).to eq work.id
        expect(identity_orcid_work.put_code.to_s).to eq put_code
      end
    end

    context "when the work has been published to ORCID" do
      before do
        # By adding the orcid work to the identity, we ensure that a PUT update request is published
        orcid_identity.orcid_works << orcid_work
        orcid_identity.save
      end

      it "calls Faraday" do
        service.publish

        expect(Faraday).to have_received(:send).with(:put, url, xml, service.send(:headers))
      end
    end
  end

  describe "#unpublish" do
    let(:put_code) { "564375" }
    let(:xml) { nil }

    before do
      allow(Faraday).to receive(:send).and_return(faraday_response)
    end

    context "when the creator is the depositor" do
      before do
        orcid_identity.orcid_works << orcid_work
        orcid_identity.save
      end

      it "calls Faraday" do
        service.unpublish

        expect(Faraday).to have_received(:send).with(:delete, url, xml, service.send(:headers))
      end

      it "destroys the orcid_work record" do
        service.unpublish

        expect(orcid_identity.reload.orcid_works).to be_empty
      end

      it "doesn't create the notification" do
        expect { service.unpublish }.not_to change { UserMailbox.new(user).inbox.count }
      end
    end

    context "when the creator is not the depositor" do
      let(:service) { described_class.new(work, orcid_identity2) }
      let(:user2) { create(:user, orcid_identity: orcid_identity2) }
      let(:orcid_identity2) { create(:orcid_identity, work_sync_preference: sync_preference) }
      let(:orcid_id) { user2.orcid_identity.orcid_id }

      before do
        orcid_identity2.orcid_works << orcid_work
        orcid_identity2.save
      end

      it "calls Faraday" do
        service.unpublish

        expect(Faraday).to have_received(:send).with(:delete, url, xml, service.send(:headers))
      end

      it "destroys the orcid_work record" do
        service.unpublish

        expect(orcid_identity.reload.orcid_works).to be_empty
      end

      it "creates the notification" do
        expect { service.unpublish }.to change { UserMailbox.new(user2).inbox.count }.by(1)
      end
    end
  end

  describe "#notify_unpublished" do

  end

  describe "#request_url" do
    context "when the work was published" do
      let(:put_code) { "123456" }
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

      before do
        orcid_identity.orcid_works << orcid_work
      end

      it { expect(service.send(:previously_uploaded?)).to be true }
    end

    context "when the work was not published" do
      it { expect(service.send(:previously_uploaded?)).to be false }
    end
  end

  describe "#headers" do
    let(:headers) { service.send(:headers) }

    it { expect(headers).to be_a(Hash) }
    it { expect(headers.dig("authorization")).to eq "Bearer #{orcid_identity.access_token}" }
  end
end
