# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HykuAddons::TaskMaster::AccountBehavior do
  subject(:account) { model_class.new(name: "example", tenant: tenant, cname: cname) }
  let(:tenant) { SecureRandom.uuid }
  let(:cname) { "example.com" }
  let(:model_class) do
    # rubocop:disable RSpec/DescribedClass
    Account.class_eval do
      include HykuAddons::TaskMaster::AccountBehavior
    end
    # rubocop:enable RSpec/DescribedClass
  end
  let(:flipflop_name) { :task_master }
  let(:flipflop_enabled) { true }

  before do
    ActiveJob::Base.queue_adapter = :test

    allow(Flipflop).to receive(:enabled?).and_call_original
    allow(Flipflop).to receive(:enabled?).with(flipflop_name).and_return(flipflop_enabled)
  end

  describe "#upsertable?" do
    it "is false for a new record" do
      expect(model_class.new.upsertable?).to be_falsey
    end

    it "is true for records with a tenant uuid" do
      expect(account.upsertable?).to be_truthy
    end
  end

  describe "#to_task_master" do
    it "returns an object" do
      expect(account.to_task_master).to be_a(Hash)
      expect(account.to_task_master[:uuid]).to eq tenant
      expect(account.to_task_master[:cname]).to eq cname
    end
  end

  describe "#task_master_uuid" do
    it "is the account tenant" do
      expect(account.task_master_uuid).to eq tenant
    end
  end

  describe "#task_master_type" do
    it "is tenant" do
      expect(account.task_master_type).to eq "tenant"
    end
  end

  describe "Callbacks" do
    context "when the feature is enabled" do
      context "when the account is created" do
        it "creates a job" do
          expect { account.save }
            .to have_enqueued_job(HykuAddons::TaskMaster::PublishJob)
            .on_queue(Hyrax.config.ingest_queue_name)
            .with("tenant", "upsert", account.to_task_master.to_json)
        end
      end

      context "when the account is updated" do
        before do
          account.save
        end

        it "creates a job" do
          expect { account.save }
            .to have_enqueued_job(HykuAddons::TaskMaster::PublishJob)
            .on_queue(Hyrax.config.ingest_queue_name)
            .with("tenant", "upsert", account.to_task_master.to_json)
        end
      end

      context "when the account is destroyed" do
        before do
          account.save
        end

        it "creates a job" do
          expect { account.destroy }
            .to have_enqueued_job(HykuAddons::TaskMaster::PublishJob)
            .on_queue(Hyrax.config.ingest_queue_name)
            .with("tenant", "destroy", { uuid: account.task_master_uuid }.to_json)
        end
      end
    end

    context "when the feature is not enabled" do
      let(:flipflop_enabled) { false }

      context "when the account is created" do
        it "creates a job" do
          expect { account.save }.not_to have_enqueued_job(HykuAddons::TaskMaster::PublishJob)
        end
      end

      context "when the account is updated" do
        before do
          account.save
        end

        it "creates a job" do
          expect { account.save }.not_to have_enqueued_job(HykuAddons::TaskMaster::PublishJob)
        end
      end

      context "when the account is destroyed" do
        before do
          account.save
        end

        it "creates a job" do
          expect { account.save }.not_to have_enqueued_job(HykuAddons::TaskMaster::PublishJob)
        end
      end
    end
  end
end
