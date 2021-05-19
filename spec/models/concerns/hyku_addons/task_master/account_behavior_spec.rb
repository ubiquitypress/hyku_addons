# frozen_string_literal: true

require 'spec_helper'

RSpec.describe HykuAddons::TaskMaster::AccountBehavior do
  subject(:model) { model_class.new(name: "example", tenant: tenant, cname: cname) }
  let(:tenant) { SecureRandom.uuid }
  let(:cname) { "example.com" }
  let(:model_class) do
    # rubocop:disable RSpec/DescribedClass
    Account.class_eval do
      include HykuAddons::TaskMaster::AccountBehavior
    end
    # rubocop:enable RSpec/DescribedClass
  end

  describe "#to_task_master" do
    it "returns an object" do
      expect(subject.to_task_master).to be_a(Hash)
      expect(subject.to_task_master[:uuid]).to eq tenant
      expect(subject.to_task_master[:cname]).to eq cname
    end
  end

  describe "#task_master_uuid" do
    it "is the account tenant" do
      expect(subject.task_master_uuid).to eq tenant
    end
  end

  describe "#task_master_type" do
    it "is tenant" do
      expect(subject.task_master_type).to eq "tenant"
    end
  end

  describe "Callbacks" do
    before do
      ActiveJob::Base.queue_adapter = :test
    end

    context "when the account is created" do
      it "creates a job" do
        expect { model.save }
          .to have_enqueued_job(HykuAddons::TaskMaster::PublishJob)
          .on_queue(Hyrax.config.ingest_queue_name)
          .with("tenant", "create", model.to_task_master)
      end
    end

    context "when the account is updated" do
      before do
        model.save
      end

      it "creates a job" do
        expect { model.save }
          .to have_enqueued_job(HykuAddons::TaskMaster::PublishJob)
          .on_queue(Hyrax.config.ingest_queue_name)
          .with("tenant", "update", model.to_task_master)
      end
    end

    context "when the account is destroyed" do
      before do
        model.save
      end

      it "creates a job" do
        expect { model.destroy }
          .to have_enqueued_job(HykuAddons::TaskMaster::PublishJob)
          .on_queue(Hyrax.config.ingest_queue_name)
          .with("tenant", "destroy", uuid: model.tenant)
      end
    end
  end
end
