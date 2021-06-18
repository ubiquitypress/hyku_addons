# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::Orcid::UnpublishWorkDelegator do
  let(:delegator) { described_class.new(work) }
  let(:sync_preference) { "sync_all" }
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
    it "creates a job" do
      expect { delegator.perform }
        .to have_enqueued_job(Hyrax::Orcid::UnpublishWorkJob)
        .on_queue(Hyrax.config.ingest_queue_name)
        .with(work, orcid_identity)
    end
  end
end
