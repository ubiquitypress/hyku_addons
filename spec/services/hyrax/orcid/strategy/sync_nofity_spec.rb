# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::Orcid::Strategy::SyncNotify do
  let(:sync_preference) { "sync_notify" }
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

  describe "#perform" do
    before do
      allow(service).to receive(:notify)
      allow(service).to receive(:publish_work)
    end

    context "when the depositor is the primary referenced user" do
      it "calls publish_work" do
        service.perform

        expect(service).to have_received(:publish_work)
      end
    end

    context "when the referenced user is not the depositor" do
      let(:service) { described_class.new(work, orcid_identity2) }
      let(:user2) { create(:user, orcid_identity: orcid_identity2) }
      let(:orcid_identity2) { create(:orcid_identity, work_sync_preference: sync_preference) }
      let(:orcid_id) { user2.orcid_identity.orcid_id }

      it "calls notify" do
        service.perform

        expect(service).to have_received(:notify)
      end
    end
  end

  describe "#publish_work" do
    it "creates a job" do
      expect { service.send(:publish_work) }
        .to have_enqueued_job(Hyrax::Orcid::PublishWorkJob)
        .on_queue(Hyrax.config.ingest_queue_name)
        .with(work, orcid_identity)
    end
  end

  describe "#primary_user?" do
    context "when the user depositing the work is referenced" do
      it "returns true" do
        expect(service.send(:primary_user?)).to be_truthy
      end
    end

    context "when the depositing user is not the user being referenced" do
      let(:service) { described_class.new(work, orcid_identity2) }
      let(:user2) { create(:user, orcid_identity: orcid_identity2) }
      let(:orcid_identity2) { create(:orcid_identity, work_sync_preference: sync_preference) }
      let(:orcid_id) { user2.orcid_identity.orcid_id }

      it "returns false" do
        expect(service.send(:primary_user?)).to be_falsey
      end
    end
  end

  describe "#notify" do
    let(:service) { described_class.new(work, orcid_identity2) }
    let(:user2) { create(:user, orcid_identity: orcid_identity2) }
    let(:orcid_identity2) { create(:orcid_identity, work_sync_preference: sync_preference) }
    let(:orcid_id) { user2.orcid_identity.orcid_id }

    it "increments the message count for the referenced user" do
      expect { service.send(:notify) }.to  change { UserMailbox.new(user2).inbox.count }.by(1)
    end
  end
end
