# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::Orcid::ProcessWorkService do
  let(:service) { described_class.new(work) }
  let(:user) { create(:user, orcid_identity: orcid_identity) }
  let(:orcid_identity) { create(:orcid_identity, work_sync_preference: work_sync_preference) }
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
  let(:work_sync_preference) { "sync_all" }

  before do
    allow(Flipflop).to receive(:enabled?).and_call_original
    allow(Flipflop).to receive(:enabled?).with(:orcid_identities).and_return(true)
  end

  describe ".new" do
    context "when arguments are used" do
      it "doesn't raise" do
        expect { described_class.new(work) }.not_to raise_error
      end
    end

    context "when invalid type is used" do
      let(:work) { "foo" }

      it "raises" do
        expect { described_class.new(work) }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#perform" do
    before do
      allow(service).to receive(:perform_user_preference).and_call_original
    end

    context "when the feature is enabled" do
      it "doesn't return nil" do
        expect(service.perform).not_to be_nil
      end

      it "calls the delegated sync class" do
        service.perform

        expect(service).to have_received(:perform_user_preference).with(orcid_id)
      end
    end

    context "when the feature is disabled" do
      before do
        allow(Flipflop).to receive(:enabled?).with(:orcid_identities).and_return(false)
      end

      it "returns nil" do
        expect(service.perform).to be_nil
      end
    end
  end

  describe "#perform_user_preference" do
    let(:sync_class) { Hyrax::Orcid::SyncAll }
    let(:sync_instance) { instance_double(sync_class, perform: "something") }

    context "when the user has selected sync_all" do
      before do
        allow(sync_class).to receive(:new).and_return(sync_instance)
      end

      it "calls the perform method on the sync class" do
        service.perform

        expect(sync_instance).to have_received(:perform).with(no_args)
      end
    end
  end
end

