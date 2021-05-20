# frozen_string_literal: true

require "rails_helper"

RSpec.describe HykuAddons::Actors::TaskMaster::WorkActor do
  let(:flipflop_name) { :task_master }
  let(:user) { build(:user) }
  let(:work) { create(:generic_work) }
  let(:ability) { ::Ability.new(user) }
  let(:attributes) { {} }
  let(:env_class) { Hyrax::Actors::Environment }
  let(:env) { env_class.new(work, ability, attributes) }
  let(:terminator) { Hyrax::Actors::Terminator.new }
  let(:options) { { action: "create" } }

  # This is an alternative to the subject(:middleware) below, but won't test the middleware chain.
  # Use it with: `actor.create(env)`
  #
  # let(:actor) { described_class.new(terminator) }

  # This lets us use the middleware chain, rather than assuming its running and using the `create` method on the actor
  let(:middleware) do
    stack = ActionDispatch::MiddlewareStack.new.tap do |middleware|
      middleware.use described_class
    end

    stack.build(terminator)
  end

  before do
    allow(Flipflop).to receive(:enabled?).and_call_original
    allow(Flipflop).to receive(:enabled?).with(flipflop_name).and_return(true)

    ActiveJob::Base.queue_adapter = :test
  end

  describe "#create" do
    context "when the flipflop is enabled" do
      before do
        allow(terminator).to receive(:create).with(env_class)
      end

      it "called the terminator" do
        middleware.create(env)

        expect(terminator).to have_received(:create).with(env_class)
      end

      it "enqueues the job" do
        expect { middleware.create(env) }
          .to have_enqueued_job(HykuAddons::TaskMasterWorkJob)
          .on_queue(Hyrax.config.ingest_queue_name)
          .with(work.id, options)
      end
    end

    context "when the flipflop is disabled" do
      before do
        allow(Flipflop).to receive(:enabled?).with(flipflop_name).and_return(false)

        allow(terminator).to receive(:create)
      end

      it "calls the termintor" do
        middleware.create(env)

        expect(terminator).to have_received(:create).with(env_class)
      end

      it "does not enqueue the job" do
        expect { middleware.create(env) }.not_to have_enqueued_job(HykuAddons::TaskMasterWorkJob)
      end
    end
  end

  describe "#update" do
    context "when the flipflop is enabled" do
      let(:options) { { action: "update" } }

      before do
        allow(terminator).to receive(:update).with(env_class)
      end

      it "called the terminator" do
        middleware.update(env)

        expect(terminator).to have_received(:update).with(env_class)
      end

      it "enqueues the job" do
        expect { middleware.update(env) }
          .to have_enqueued_job(HykuAddons::TaskMasterWorkJob)
          .on_queue(Hyrax.config.ingest_queue_name)
          .with(work.id, options)
      end
    end

    context "when the flipflop is disabled" do
      before do
        allow(Flipflop).to receive(:enabled?).with(flipflop_name).and_return(false)

        allow(terminator).to receive(:update)
      end

      it "calls the termintor" do
        middleware.update(env)

        expect(terminator).to have_received(:update).with(env_class)
      end

      it "does not enqueue the job" do
        expect { middleware.update(env) }.not_to have_enqueued_job(HykuAddons::TaskMasterWorkJob)
      end
    end
  end

  describe "#destroy" do
    context "when the flipflop is enabled" do
      let(:options) { { action: "destroy" } }

      before do
        allow(terminator).to receive(:destroy).with(env_class)
      end

      it "called the terminator" do
        middleware.destroy(env)

        expect(terminator).to have_received(:destroy).with(env_class)
      end

      it "enqueues the job" do
        expect { middleware.destroy(env) }
          .to have_enqueued_job(HykuAddons::TaskMasterWorkJob)
          .on_queue(Hyrax.config.ingest_queue_name)
          .with(work.id, options)
      end
    end

    context "when the flipflop is disabled" do
      before do
        allow(Flipflop).to receive(:enabled?).with(flipflop_name).and_return(false)

        allow(terminator).to receive(:destroy)
      end

      it "calls the termintor" do
        middleware.destroy(env)

        expect(terminator).to have_received(:destroy).with(env_class)
      end

      it "does not enqueue the job" do
        expect { middleware.destroy(env) }.not_to have_enqueued_job(HykuAddons::TaskMasterWorkJob)
      end
    end
  end
end
