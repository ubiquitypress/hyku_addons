# frozen_string_literal: true

RSpec.describe HykuAddons::ImportMode, type: :job do
  before do
    allow(Apartment::Tenant).to receive(:current).and_return("x")
    allow(Account).to receive(:find_by).with(tenant: "x").and_return(account)
    allow(Apartment::Tenant).to receive(:switch).with("x") do |&block|
      block.call
    end
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

      before do
        allow(Bulkrax::Entry).to receive(:find).and_return(nil)
        allow(ActiveFedora::Base).to receive(:find).and_return(nil)
      end

      context "a generic job" do
        it "returns super if not in import mode" do
          expect(job.new.queue_name).to eq "test"
        end
      end

      context "an import job" do
        [Bulkrax::Entry, ActiveFedora::Base].each do |object_type|
          context "the job processes a #{object_type}" do
            let(:object) { double }

            before do
              if object_type == Bulkrax::Entry
                job.include HykuAddons::PortableBulkraxEntryBehavior
              elsif object_type == ActiveFedora::Base
                job.include HykuAddons::PortableActiveFedoraBehavior
              end

              allow(object_type).to receive(:find).and_return(object)
            end

            it "returns special queue name if the entry is marked bulk" do
              allow(object).to receive(:bulk).and_return(true)

              expect(job.new.queue_name).to eq "moominU_import_test"
            end

            it "returns super if the entry is not marked bulk" do
              allow(object).to receive(:bulk).and_return(false)

              expect(job.new.queue_name).to eq "test"
            end
          end
        end
      end
    end
  end
end
