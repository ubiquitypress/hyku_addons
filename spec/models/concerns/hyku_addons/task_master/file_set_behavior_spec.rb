# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HykuAddons::TaskMaster::FileSetBehavior do
  subject(:file_set) { create(:file_set, user: user, title: ['A Contained PDF FileSet'], label: 'filename.pdf') }
  let(:user) { create(:user) }
  let(:work) { create(:task_master_work) }

  before do
    work.ordered_members << file_set
    work.save
  end

  describe "#upsertable?" do
    it "is false for a new record" do
      expect(build(:file_set).upsertable?).to be_falsey
    end

    it "is true for saved records" do
      expect(file_set.upsertable?).to be_truthy
    end
  end

  describe "#to_task_master" do
    it "returns an object" do
      expect(file_set.to_task_master).to be_a(Hash)
      expect(file_set.to_task_master[:uuid]).to eq file_set.id
      expect(file_set.to_task_master[:work]).to eq work.id
    end
  end

  describe "#task_master_uuid" do
    it "is the file set ID" do
      expect(file_set.task_master_uuid).to eq file_set.id
    end
  end

  describe "#task_master_type" do
    it "is file" do
      expect(file_set.task_master_type).to eq "file"
    end
  end

  describe "Callbacks" do
    context "when the file set is destroyed" do
      it "creates a job" do
        expect { file_set.destroy }
          .to have_enqueued_job(HykuAddons::TaskMaster::PublishJob)
          .on_queue(Hyrax.config.ingest_queue_name)
          .with("file", "destroy", { uuid: file_set.task_master_uuid }.to_json)
      end
    end
  end
end
