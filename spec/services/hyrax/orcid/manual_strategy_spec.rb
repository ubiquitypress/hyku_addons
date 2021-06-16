# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::Orcid::ManualStrategy do
  let(:sync_preference) { "manual" }
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
      it "does nothing" do
        expect(service.perform).to be_nil
      end
    end

    context "when the referenced user is not the depositor" do
      it "does nothing" do
        expect(service.perform).to be_nil
      end
    end
  end
end

