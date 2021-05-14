# frozen_string_literal: true

require "rails_helper"

RSpec.describe HykuAddons::TaskMasterJob do
  let(:work) { create(:work) }
  let(:service_class) { HykuAddons::TaskMasterService }
  let(:service) { service_class.new(work.id) }

  describe ".perform_later" do
    before { ActiveJob::Base.queue_adapter = :test }

    it "enqueues the job" do
      expect { described_class.perform_later(work.id) }
        .to enqueue_job(described_class)
        .with(work.id)
        .on_queue(Hyrax.config.ingest_queue_name)
    end
  end

  describe ".perform" do
    before do
      allow(service_class).to receive(:new).with(work.id).and_return(service)
    end

    it "calls the service" do
      allow(service).to receive(:perform)

      described_class.perform_now(work.id)

      expect(service).to have_received(:perform).with(no_args)
    end
  end
end
