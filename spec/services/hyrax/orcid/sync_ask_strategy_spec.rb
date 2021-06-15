# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::Orcid::SyncAskStrategy do
  let(:service) { described_class.new(work, orcid_identity) }
  let(:user) { create(:user, orcid_identity: orcid_identity) }
  let(:orcid_identity) { create(:orcid_identity, work_sync_preference: "sync_all") }
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
    context "when the depositor is the primary referenced user" do

    end

    context "when the referenced user is not the depositor" do

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

    end

    context "when the depositing user is not the user being referenced" do

    end
  end

  describe "#notify" do
    it "increments the message count for the referenced user" do
    end
  end
end
