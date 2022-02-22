# frozen_string_literal: true

RSpec.describe HykuAddons::ImportMode, type: :job do
  let(:job) do
    Class.new(ApplicationJob) do
      queue_as :test
    end
  end

  describe "queue_name" do
    context "with non_tenant_job" do
      let(:job) do
        Class.new(ApplicationJob) do
          non_tenant_job
          queue_as :test
        end
      end

      it "returns original queue name if non_tenant_job" do
        expect(job.new.queue_name).to eq "test"
      end
    end

    context "with a tenant job" do
      let(:account) { FactoryBot.build(:account, name: "moominU") }

      before do
        allow(Apartment::Tenant).to receive(:current).and_return("x")
        allow(Account).to receive(:find_by).with(tenant: "x").and_return(account)
        allow(Apartment::Tenant).to receive(:switch).with("x") do |&block|
          block.call
        end
      end

      context "a job without a strategy included" do
        it "returns original queue name" do
          expect(job.new.queue_name).to eq "test"
        end
      end

      # rubocop:disable RSpec/MessageChain
      [HykuAddons::PortableBulkraxEntryBehavior, HykuAddons::PortableBulkraxImporterBehavior, HykuAddons::PortableActiveFedoraBehavior, HykuAddons::PortableGenericBehavior].each do |strategy|
        context "the job with #{strategy} included" do
          let(:bulkrax_entry) { double }
          let(:bulkrax_importer) { double }
          let(:bulkrax_importer_run) { double }

          before do
            job.include strategy

            if strategy == HykuAddons::PortableActiveFedoraBehavior
              allow(ActiveFedora::Base).to receive_message_chain(:find, :source_identifier)
            elsif strategy == HykuAddons::PortableBulkraxImporterBehavior
              allow(Bulkrax::Importer).to receive(:find).and_return(bulkrax_importer)
              allow(bulkrax_importer).to receive_message_chain(:importer_runs, :first).and_return(bulkrax_importer_run)
            end

            allow(Bulkrax::Entry).to receive(:find_by_identifier).and_return(bulkrax_entry)
            allow(bulkrax_entry).to receive_message_chain(:importerexporter, :importer_runs, :first).and_return(bulkrax_importer_run)
          end

          it "returns special queue name if the entry is marked bulk" do
            allow(bulkrax_importer_run).to receive(:total_collection_entries).and_return(25)

            expect(job.new.queue_name).to eq "moominU_import_test"
          end

          it "returns super if the entry is not marked bulk" do
            allow(bulkrax_importer_run).to receive(:total_collection_entries).and_return(2)

            expect(job.new.queue_name).to eq "test"
          end
        end
      end
      # rubocop:enable RSpec/MessageChain
    end
  end
end
