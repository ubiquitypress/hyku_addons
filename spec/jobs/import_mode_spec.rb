# frozen_string_literal: true

RSpec.describe HykuAddons::ImportMode do
  before do
    allow(Apartment::Tenant).to receive(:current).and_return("x")
    allow(Account).to receive(:find_by).with(tenant: "x").and_return(account)
    allow(Apartment::Tenant).to receive(:switch).with("x") do |&block|
      block.call
    end

    allow(Flipflop).to receive(:enabled?).with(:import_mode).and_return(import_mode)
  end

  let(:job) do
    Class.new(ApplicationJob) do
      queue_as :test
    end
  end
  let(:account) { FactoryBot.build(:account, name: "moominU") }
  let(:import_mode) { false }

  describe "queue_name" do
    context "with non_tenant_job" do
      let(:job) do
        Class.new(ApplicationJob) do
          non_tenant_job
          queue_as :test
        end
      end

      it "returns super if non_tenant_job" do
        expect(job.new.queue_name).to eq "test"
      end
    end

    context "when not in import mode" do
      it "returns super if not in import mode" do
        expect(job.new.queue_name).to eq "test"
      end
    end

    context "when in import mode" do
      let(:import_mode) { true }

      it "returns special queue name if in import mode" do
        expect(job.new.queue_name).to eq "moominU_import_test"
      end
    end
  end
end
