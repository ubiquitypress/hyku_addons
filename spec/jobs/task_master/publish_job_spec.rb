# frozen_string_literal: true

RSpec.describe HykuAddons::TaskMaster::PublishJob, type: :job do
  let(:work) { create(:work) }
  let(:service_class) { HykuAddons::TaskMaster::PublishService }
  let(:service) { service_class.new(type, action, json) }
  let(:type) { "work" }
  let(:action) { "upsert" }
  let(:json) { work.to_task_master.to_json }
  let(:account) { create(:account) }
  let(:site) { Site.new(account: account) }

  before do
    allow(Site).to receive(:instance).and_return(site)
  end

  it "has its callback available" do
    expect(Hyrax.config.callback.enabled).to include(:task_master_after_create_fileset)
  end

  describe ".perform_later" do
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
