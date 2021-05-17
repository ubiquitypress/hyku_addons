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
    context "when the action is valid" do
      it "raised an error" do
        expect { service.perform }.not_to raise_error
      end


    end

    context "when the action is not valid" do
      let(:options) { { action: "foo" } }

      it "raised an error" do
        expect { service.perform }.to raise_error(ArgumentError)
      end
    end
  end
end
