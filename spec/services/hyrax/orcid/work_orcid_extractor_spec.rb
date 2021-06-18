# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::Orcid::WorkOrcidExtractor do
  let(:service) { described_class.new(work) }
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
  let(:orcid_id2) { "0000-1111-2222-3333" }

  describe ".new" do
    context "when arguments are used" do
      it "doesn't raise" do
        expect { described_class.new(work) }.not_to raise_error
      end
    end

    context "when invalid type is used" do
      it "raises" do
        expect { described_class.new("not_a_work") }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#extract" do
    it "returns an array" do
      expect(service.extract).to be_a(Array)
    end

    it "includes the orcid_id" do
      expect(service.extract).to include(orcid_id)
    end

    context "when there are multiple creators" do
      let(:work_attributes) do
        {
          "title" => ["Moomin"],
          "creator" => [
            [{
              "creator_given_name" => "Smith",
              "creator_family_name" => "John",
              "creator_name_type" => "Personal",
              "creator_orcid" => orcid_id
            }, {
              "creator_given_name" => "Smithison",
              "creator_family_name" => "Johna",
              "creator_name_type" => "Personal",
              "creator_orcid" => orcid_id2
            }].to_json
          ]
        }
      end

      it "includes both the orcid_id" do
        expect(service.extract).to include(orcid_id, orcid_id2)
      end
    end
  end

  describe "#target_terms" do
    it "is an array of symbols" do
      expect(service.target_terms).to be_a(Array)
      expect(service.target_terms.all? { |val| val.is_a?(Symbol) }).to be_truthy
    end
  end
end
