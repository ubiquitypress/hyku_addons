# frozen_string_literal: true

require "rails_helper"

RSpec.describe HykuAddons::TaskMaster::PublishJob do
  let(:work) { create(:work) }
  let(:service_class) { HykuAddons::TaskMaster::PublishService }
  let(:service) { service_class.new(type, action, json) }
  let(:type) { "work" }
  let(:action) { "create" }
  let(:json) { work.to_task_master.to_json }
  let(:account) { create(:account) }
  let(:site) { Site.new(account: account) }

  before do
    allow(Site).to receive(:instance).and_return(site)
  end

  describe ".perform_later" do
    before { ActiveJob::Base.queue_adapter = :test }

    it "enqueues the job" do
      expect { described_class.perform_later(type, action, json) }
        .to enqueue_job(described_class)
        .on_queue(Hyrax.config.ingest_queue_name)
        .with(type, action, json)
    end
  end

  describe ".perform" do
    before do
      allow(service_class).to receive(:new).with(type, action, json).and_return(service)
    end

    it "calls the service" do
      allow(service).to receive(:perform)

      described_class.perform_now(type, action, json)

      expect(service).to have_received(:perform).with(no_args)
    end
  end
end
