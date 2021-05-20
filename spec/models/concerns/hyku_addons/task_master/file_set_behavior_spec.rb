# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HykuAddons::TaskMaster::FileSetBehavior do
  subject(:file) { create(:file_set, user: user, title: ['A Contained PDF FileSet'], label: 'filename.pdf') }
  let(:user) { create(:user) }
  let(:work) { create(:task_master_work, :with_one_file) }
  let(:model_class) do
    # rubocop:disable Lint/UnneededDisable
    # rubocop:disable RSpec/DescribedClass
    FileSet.class_eval do
      include HykuAddons::TaskMaster::FileSetBehavior
    end
    # rubocop:enable RSpec/DescribedClass
    # rubocop:enable Lint/UnneededDisable
  end

  before do
    work.ordered_members << subject
    work.save
  end

  describe "#to_task_master" do
    it "returns an object" do
      expect(subject.to_task_master).to be_a(Hash)
      expect(subject.to_task_master[:uuid]).to eq file.id
      expect(subject.to_task_master[:work]).to eq work.id
    end
  end

  describe "#task_master_uuid" do
    it "is the file tenant" do
      expect(subject.task_master_uuid).to eq file.id
    end
  end

  describe "#task_master_type" do
    it "is file" do
      expect(subject.task_master_type).to eq "file"
    end
  end
end

