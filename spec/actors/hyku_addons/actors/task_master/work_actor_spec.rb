# frozen_string_literal: true

require "spec_helper"

RSpec.describe HykuAddons::Actors::TaskMaster::WorkActor do
  subject(:work) { build_stubbed(:task_master_work, :with_one_file) }
  let(:account) { create(:account) }
  let(:site) { Site.new(account: account) }
  let(:job_class) { HykuAddons::TaskMaster::PublishJob }
  let(:type) { "work" }
  let(:action) { "upsert" }
  let(:json) { work.to_task_master.to_json }

  let(:flipflop_name) { :task_master }
  let(:flipflop_enabled) { true }

  # Middleware Setup
  let(:attributes) { {} }
  let(:user) { build_stubbed(:user) }
  let(:ability) { ::Ability.new(user) }
  let(:env_class) { Hyrax::Actors::Environment }
  let(:env) { env_class.new(work, ability, attributes) }
  let(:terminator) { Hyrax::Actors::Terminator.new }
  let(:middleware) do
    stack = ActionDispatch::MiddlewareStack.new.tap do |middleware|
      middleware.use described_class
    end

    stack.build(terminator)
  end

  before do
    allow(Site).to receive(:instance).and_return(site)
    allow(Flipflop).to receive(:enabled?).and_call_original
    allow(Flipflop).to receive(:enabled?).with(flipflop_name).and_return(flipflop_enabled)
  end

  describe "#create" do
    context "when the feature is enabled" do
      before do
        allow(terminator).to receive(:create).with(env_class)
      end

      it "calls the terminator" do
        middleware.create(env)

        expect(terminator).to have_received(:create).with(env_class)
      end

      it "enqueues a job" do
        expect { middleware.create(env) }
          .to enqueue_job(job_class)
          .on_queue(Hyrax.config.ingest_queue_name)
          .with(type, action, json)
      end
    end

    context "when the feature is not enabled" do
      let(:flipflop_enabled) { false }

      before do
        allow(terminator).to receive(:create)
      end

      it "calls the terminator" do
        middleware.create(env)

        expect(terminator).to have_received(:create).with(env_class)
      end

      it "doesn't enqueue a job" do
        expect { middleware.create(env) }.not_to enqueue_job(job_class)
      end
    end
  end

  describe "#update" do
    let(:action) { "upsert" }

    context "when the feature is enabled" do
      before do
        allow(terminator).to receive(:update).with(env_class)
      end

      it "calls the terminator" do
        middleware.update(env)

        expect(terminator).to have_received(:update).with(env_class)
      end

      it "enqueues a job" do
        expect { middleware.update(env) }
          .to enqueue_job(job_class)
          .on_queue(Hyrax.config.ingest_queue_name)
          .with(type, action, json)
      end
    end

    context "when the feature is not enabled" do
      let(:flipflop_enabled) { false }

      before do
        allow(terminator).to receive(:update)
      end

      it "calls the terminator" do
        middleware.update(env)

        expect(terminator).to have_received(:update).with(env_class)
      end

      it "doesn't enqueue a job" do
        expect { middleware.update(env) }.not_to enqueue_job(job_class)
      end
    end
  end
end
