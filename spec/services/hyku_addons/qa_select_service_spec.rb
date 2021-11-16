# frozen_string_literal: true
require "rails_helper"

RSpec.describe HykuAddons::QaSelectService do
  let(:default_authority_map) do
    [
      HashWithIndifferentAccess.new(term: "Active Label", label: "Active Label", id: "active-id", active: true),
      HashWithIndifferentAccess.new(term: "Inactive Label", label: "Inactive Label", id: "inactive-id", active: false),
      HashWithIndifferentAccess.new(label: "Active No Term", id: "active-no-term-id", active: true)
    ]
  end
  let(:model_authority_map) do
    [
      HashWithIndifferentAccess.new(term: "Model Active Label", label: "Model Active Label", id: "model-active-id", active: true)
    ]
  end
  let(:tenant_authority_map) do
    [
      HashWithIndifferentAccess.new(term: "Tenant Active Label", label: "Tenant Active Label", id: "tenant-active-id", active: true)
    ]
  end
  let(:model_tenant_authority_map) do
    [
      HashWithIndifferentAccess.new(term: "Model Tenant Active Label", label: "Model Tenant Active Label", id: "model-tenant-active-id", active: true)
    ]
  end

  let(:authority) { FakeAuthority }
  let(:authority_name) { "respect_my" }
  let(:tenant_authority_name) { "#{authority_name}-TENANT" }
  let(:model_authority_name) { "#{authority_name}-MODEL_CLASS" }
  let(:model_tenant_authority_name) { "#{authority_name}-MODEL_CLASS-TENANT" }
  let(:qa_select_service) { described_class.new(authority_name) }
  let(:model_class) { Class.new }
  let(:account) { build(:account, name: "tenant") }
  let(:site) { Site.new(account: account) }
  let(:subauthorities) { [authority_name] }

  before do
    allow(Qa::Authorities::Local).to receive(:subauthority_for).with(authority_name).and_return(authority.new(default_authority_map))
    allow(Qa::Authorities::Local).to receive(:subauthority_for).with(model_authority_name).and_return(authority.new(model_authority_map))
    allow(Qa::Authorities::Local).to receive(:subauthority_for).with(tenant_authority_name).and_return(authority.new(tenant_authority_map))
    allow(Qa::Authorities::Local).to receive(:subauthority_for).with(model_tenant_authority_name).and_return(authority.new(model_tenant_authority_map))
    allow(Qa::Authorities::Local).to receive(:subauthorities).and_return(subauthorities)
    allow(Site).to receive(:instance).and_return(site)
    stub_const("ModelClass", model_class)
  end

  describe "#select_all_options" do
    context "with no overrides" do
      it "will be default terms" do
        expect(described_class.new(authority_name).select_all_options).to eq([["Active Label", "active-id"], ["Inactive Label", "inactive-id"], ["Active No Term", "active-no-term-id"]])
      end
    end

    context "with tenant override" do
      let(:subauthorities) { [authority_name, tenant_authority_name] }

      it "will be tenant terms" do
        expect(described_class.new(authority_name).select_all_options).to eq([["Tenant Active Label", "tenant-active-id"]])
      end
    end

    context "with model override" do
      let(:subauthorities) { [authority_name, model_authority_name, tenant_authority_name] }

      it "will be model terms" do
        expect(described_class.new(authority_name, model: ModelClass).select_all_options).to eq([["Model Active Label", "model-active-id"]])
      end
    end

    context "with model tenant override" do
      let(:subauthorities) { [authority_name, model_tenant_authority_name, model_authority_name, tenant_authority_name] }

      it "will be model tenant terms" do
        expect(described_class.new(authority_name, model: ModelClass).select_all_options).to eq([["Model Tenant Active Label", "model-tenant-active-id"]])
      end
    end
  end
end
