# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HykuAddons::TaskMasterWorkService do
  subject(:service) { described_class.new(work.id, options) }
  let(:options) { { action: "create" } }
  let(:work) { create(:task_master_work, :with_one_file) }

  let(:site) { Site.new(account: account) }
  let(:account) { create(:account) }

  before do
    allow(Site).to receive(:instance).and_return(site)
  end

  describe "#perform" do
  end

  describe "#topic_for" do
    context "when the action is create" do
      it "doesn't raise an error" do
        expect { service.send(:topic_for, :work) }.not_to raise_error
      end

      it "provides a formatted string" do
        expect(service.send(:topic_for, :work)).to eq "repository--work-create"
        expect(service.send(:topic_for, :file)).to eq "repository--file-create"
      end
    end

    context "when the action is update" do
      let(:options) { { action: "update" } }

      it "doesn't raise an error" do
        expect { service.send(:topic_for, :work) }.not_to raise_error
      end

      it "provides a formatted string" do
        expect(service.send(:topic_for, :work)).to eq "repository--work-update"
        expect(service.send(:topic_for, :file)).to eq "repository--file-update"
      end
    end

    context "when the action is destroy" do
      let(:options) { { action: "destroy" } }

      it "doesn't raise an error" do
        expect { service.send(:topic_for, :work) }.not_to raise_error
      end

      it "provides a formatted string" do
        expect(service.send(:topic_for, :work)).to eq "repository--work-destroy"
        expect(service.send(:topic_for, :file)).to eq "repository--file-destroy"
      end
    end

    context "when the action is not valid" do
      let(:options) { { action: "foo" } }

      it "raised an error" do
        expect { service.send(:topic_for, :work) }.to raise_error(ArgumentError)
      end
    end
  end
end
