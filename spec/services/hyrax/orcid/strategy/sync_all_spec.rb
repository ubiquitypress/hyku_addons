# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::Orcid::Strategy::SyncAll do
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

  describe "#perform" do
    context "when the depositor is the primary referenced user" do
      it "creates a job" do
        expect { service.perform }
          .to have_enqueued_job(Hyrax::Orcid::PublishWorkJob)
          .on_queue(Hyrax.config.ingest_queue_name)
          .with(work, orcid_identity)
      end
    end

    context "when the referenced user is not the depositor" do
      let(:service) { described_class.new(work, orcid_identity2) }
      let(:user2) { create(:user, orcid_identity: orcid_identity2) }
      let(:orcid_identity2) { create(:orcid_identity, work_sync_preference: sync_preference) }
      let(:orcid_id) { user2.orcid_identity.orcid_id }

      it "creates a job" do
        expect { service.perform }.to have_enqueued_job(Hyrax::Orcid::PublishWorkJob)
      end
    end
  end
end
