# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HykuAddons::TaskMaster::WorkBehavior do
  subject(:work) { create(:task_master_work, :with_one_file) }
  let(:account) { create(:account) }
  let(:site) { Site.new(account: account) }

  before do
    allow(Site).to receive(:instance).and_return(site)
  end

  describe "#to_task_master" do
    it "returns an object" do
      expect(subject.to_task_master).to be_a(Hash)
      expect(subject.to_task_master[:uuid]).to eq work.id
      expect(subject.to_task_master[:tenant]).to eq account.tenant
    end
  end

  describe "#task_master_uuid" do
    it "is the work id" do
      expect(subject.task_master_uuid).to eq work.id
    end
  end

  describe "#task_master_type" do
    it "is work" do
      expect(subject.task_master_type).to eq "work"
    end
  end
end

