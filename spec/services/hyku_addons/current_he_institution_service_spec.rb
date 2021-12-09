# frozen_string_literal: true
require "rails_helper"

RSpec.describe HykuAddons::CurrentHeInstitutionService do
  subject(:authority) { described_class.new(model: model) }
  let(:model) { UbiquityTemplateWork }

  let(:account) { build(:account, name: "tenant") }
  let(:site) { Site.new(account: account) }

  before do
    allow(Site).to receive(:instance).and_return(site)

    # Override the path/filename to use our fixture
    Qa::Authorities::Local::FileBasedAuthority.class_eval do
      def subauthority_filename
        File.join(HykuAddons::Engine.root.join("spec", "fixtures", "yaml"), "#{subauthority}.yml")
      end
    end
  end

  describe "#select_active_options_isni" do
    let(:active_isnis) { authority.select_active_options_isni }

    it "will be default terms" do
      expect(active_isnis).to be_a(Array)
    end

    it "returns the correct ISNI" do
      expect(active_isnis).to eq(["1234 5678 9012 3456", "0000 0001 2168 2483", "0000 0001 2299 5510"])
    end

    it "returns the correct number of ISNIs" do
      expect(active_isnis.count).to eq(3)
    end
  end

  describe "#select_active_options_ror" do
    let(:active_rors) { authority.select_active_options_ror }

    it "will be default terms" do
      expect(active_rors).to be_a(Array)
    end

    it "returns the correct ROR" do
      expect(active_rors).to eq(["https://ror.org/bognor1", "https://ror.org/015m2p889", "https://ror.org/0009t4v78"])
    end

    it "returns the correct number of RORs" do
      expect(active_rors.count).to eq(3)
    end
  end

  describe "#quick_active_elements" do
    let(:active_elements) { authority.send(:quick_active_elements) }

    it "returns an array of hashes" do
      expect(active_elements).to be_a(Array)
      expect(active_elements.map(&:class).uniq).to eq([ActiveSupport::HashWithIndifferentAccess])
    end

    it "has the correct keys in the hashes" do
      expect(active_elements.first.keys).to match_array(["id", "term", "isni", "ror", "active"])
    end
  end
end
