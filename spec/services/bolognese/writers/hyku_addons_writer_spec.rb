# frozen_string_literal: true
require "rails_helper"

RSpec.describe Bolognese::Writers::HykuAddonsWriter do
  describe "#hyku_addons_work" do
    it "responds to the method" do
      expect(Bolognese::Metadata.new).to respond_to(:hyku_addons_work)
    end
  end

  context "Hyku Addons Writer" do
    context "outputs correctly" do
      describe "a complete work" do
        let(:fixture) { File.read Rails.root.join('..', 'fixtures', 'work_from_doi_complete.xml') }
        let(:meta) { Bolognese::Metadata.new(input: fixture) }
        let(:result) { meta.hyku_addons_work }

        it { expect(meta.doi).to be_present }
        it { expect(result).to be_a Hash }
        it { expect(result["publisher"]).to eq ["Ubiquity Press, Ltd."] }
        it { expect(result["title"]).to eq ["As Paisagens Sonora, Olfactiva e Culinária em Alice’s Adventures in Wonderland (1865), de Lewis Carroll"] }
        it { expect(result["doi"]).to eq ["10.5334/as.1"] }

        it { expect(result["creator"]).to be_an(Array) }
        it { expect(result["creator"].first["creator_given_name"]).to eq "Rogério Miguel" }
        it { expect(result["creator"].first["creator_family_name"]).to eq "Puga" }

        it { expect(result["date_created"]).to be_an(Array) }
        it { expect(result["date_created"].first["date_created_year"]).to be 2020 }
        it { expect(result["date_created"].first["date_created_month"]).to be 2 }
        it { expect(result["date_created"].first["date_created_day"]).to be 14 }

        it { expect(result["date_updated"]).to be_an(Array) }
        it { expect(result["date_updated"].first["date_updated_year"]).to be 2020 }
        it { expect(result["date_updated"].first["date_updated_month"]).to be 12 }
        it { expect(result["date_updated"].first["date_updated_day"]).to be 18 }

        it { expect(result["date_published"]).to be_an(Array) }
        it { expect(result["date_published"].first["date_published_year"]).to be 2020 }
        it { expect(result["date_published"].first["date_published_month"]).to be 1 }
        it { expect(result["date_published"].first["date_published_day"]).to be 1 }
      end
    end
  end
end
