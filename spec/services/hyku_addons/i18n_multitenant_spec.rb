# frozen_string_literal: true
require "rails_helper"

RSpec.describe HykuAddons::I18nMultitenant do
  let(:options) { { locale: :en, tenant: "Test" } }

  # Configure is run when the application starts and so should be present by default including the fallback methods
  it "adds I18n::Backend::Fallbacks" do
    expect(I18n.methods).to include(:fallbacks)
  end

  describe ".set" do
    it "changes the locale" do
      expect(I18n.locale).to eq(:en)

      described_class.set(options)

      expect(I18n.locale).to eq(:"en-TEST")
    end
  end

  describe "._locale_for" do
    it "returns the correctly formatted string" do
      expect(described_class._locale_for(options)).to eq("en-TEST")
      expect(described_class._locale_for(locale: :en)).to eq("en")
      expect(described_class._locale_for(locale: "pt-BR", tenant: "Test")).to eq("pt-BR-TEST")
    end
  end

  describe ".processed_tenant" do
    it { expect(described_class.processed_tenant("Test")).to eq("TEST") }
    it { expect(described_class.processed_tenant("test")).to eq("TEST") }
    it { expect(described_class.processed_tenant("another test")).to eq("ANOTHER_TEST") }
    it { expect(described_class.processed_tenant("another.test")).to eq("ANOTHER_TEST") }
  end
end
