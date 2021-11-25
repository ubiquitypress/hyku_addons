# frozen_string_literal: true

require "spec_helper"

RSpec.describe HykuAddons::TaskMaster::WorkBehavior do
  subject(:work) { create(:task_master_work, :with_one_file) }
  let(:account) { create(:account) }
  let(:site) { Site.new(account: account) }

  before do
    allow(Site).to receive(:instance).and_return(site)
    allow(Flipflop).to receive(:enabled?).and_call_original
    allow(Flipflop).to receive(:enabled?).with(:task_master).and_return(true)
  end

  describe "#upsertable?" do
    it "is false for a new record" do
      expect(build(:task_master_work).upsertable?).to be_falsey
    end

    it "is true for saved records" do
      expect(work.upsertable?).to be_truthy
    end
  end

  describe "#to_task_master" do
    it "returns an object" do
      expect(work.to_task_master).to be_a(Hash)
      expect(work.to_task_master[:uuid]).to eq work.id
      expect(work.to_task_master[:tenant]).to eq account.tenant
    end
  end

  describe "#task_master_uuid" do
    it "is the work id" do
      expect(work.task_master_uuid).to eq work.id
    end
  end

  describe "#task_master_type" do
    it "is work" do
      expect(work.task_master_type).to eq "work"
    end
  end

  describe "Callbacks" do
    context "when the work is destroyed" do
      it "creates a job" do
        expect { work.destroy }
          .to have_enqueued_job(HykuAddons::TaskMaster::PublishJob)
          .on_queue(Hyrax.config.ingest_queue_name)
          .with("work", "destroy", { uuid: work.task_master_uuid }.to_json)
      end
    end
  end
end
