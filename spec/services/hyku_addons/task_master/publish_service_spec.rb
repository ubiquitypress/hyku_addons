# frozen_string_literal: true

require 'rails_helper'

RSpec.describe HykuAddons::TaskMaster::PublishService do
  subject(:service) { described_class.new(type, action, json) }
  let(:options) { { action: "create" } }
  let(:type) { "tenant" }
  let(:action) { "create" }
  let(:json) { "" }

  describe ".new" do
    context "when arguments are used" do
      it "doesn't raise" do
        expect { described_class.new(type, action, json) }.not_to raise_error
      end
    end

    context "when invalid type is used" do
      let(:type) { "foo" }

      it "raises" do
        expect { described_class.new(type, action, json) }.to raise_error(ArgumentError)
      end
    end

    context "when invalid action is used" do
      let(:action) { "foo" }

      it "raises" do
        expect { described_class.new(type, action, json) }.to raise_error(ArgumentError)
      end
    end

    context "when invalid data is used" do
      let(:json) { {} }

      it "raises" do
        expect { described_class.new(type, action, json) }.to raise_error(ArgumentError)
      end
    end
  end

  describe "#topic_name" do
    context "when the action is create" do
      it "provides a formatted string" do
        expect(service.send(:topic_name)).to eq "repository--tenant-create"
      end
    end

    context "when the action is update" do
      let(:action) { "update" }

      it "provides a formatted string" do
        expect(service.send(:topic_name)).to eq "repository--tenant-update"
      end
    end

    context "when the action is destroy" do
      let(:action) { "destroy" }

      it "provides a formatted string" do
        expect(service.send(:topic_name)).to eq "repository--tenant-destroy"
      end
    end

    context "when the type is work" do
      let(:type) { "work" }

      it "provides a formatted string" do
        expect(service.send(:topic_name)).to eq "repository--work-create"
      end
    end

    context "when the type is file" do
      let(:type) { "file" }
      let(:action) { "destroy" }

      it "provides a formatted string" do
        expect(service.send(:topic_name)).to eq "repository--file-destroy"
      end
    end
  end
end
