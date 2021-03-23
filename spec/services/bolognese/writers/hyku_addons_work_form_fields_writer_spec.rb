# frozen_string_literal: true
require "rails_helper"

RSpec.describe Bolognese::Writers::HykuAddonsWorkFormFieldsWriter do
  describe "#hyku_addons_work" do
    it "responds to the method" do
      expect(Bolognese::Metadata.new).to respond_to(:hyku_addons_work_form_fields)
    end
  end

  context "Hyku Addons Writer" do
    let(:meta) { Bolognese::Metadata.new(input: fixture) }
    let(:result) { meta.hyku_addons_work_form_fields }

    describe "10.5334-as.1.xml" do
      let(:fixture) { File.read Rails.root.join('..', 'fixtures', 'doi', '10.5334-as.1.xml') }

      it { expect(meta.doi).to be_present }
      it { expect(result).to be_a Hash }
      it { expect(result["publisher"]).to eq ["Ubiquity Press, Ltd."] }
      it { expect(result["title"]).to eq ["As Paisagens Sonora, Olfactiva e Culinária em Alice’s Adventures in Wonderland (1865), de Lewis Carroll"] }
      it { expect(result["doi"]).to eq ["10.5334/as.1"] }

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

      it { expect(result["creator"]).to be_an(Array) }
      it { expect(result["creator"].first["creator_given_name"]).to eq "Rogério Miguel" }
      it { expect(result["creator"].first["creator_family_name"]).to eq "Puga" }
    end

    describe "10.7554-elife.63646.xml, a journal doi with multiple complete creators" do
      let(:fixture) { File.read Rails.root.join('..', 'fixtures', 'doi', '10.7554-elife.63646.xml') }

      it { expect(meta.doi).to be_present }
      it { expect(result).to be_a Hash }
      it { expect(result["publisher"]).to eq ["eLife Sciences Publications, Ltd"] }
      it { expect(result["title"]).to eq ["SARS-CoV-2 S protein:ACE2 interaction reveals novel allosteric targets"] }
      it { expect(result["doi"]).to eq ["10.7554/elife.63646"] }

      it { expect(result["description"].first).to include("The spike (S) protein is the main handle for SARS-CoV-2") }
      it { expect(result["keywords"]).to be_nil }

      it { expect(result["date_created"]).to be_an(Array) }
      it { expect(result["date_created"].first["date_created_year"]).to be 2021 }
      it { expect(result["date_created"].first["date_created_month"]).to be 2 }
      it { expect(result["date_created"].first["date_created_day"]).to be 8 }

      it { expect(result["date_updated"]).to be_an(Array) }
      it { expect(result["date_updated"].first["date_updated_year"]).to be 2021 }
      it { expect(result["date_updated"].first["date_updated_month"]).to be 3 }
      it { expect(result["date_updated"].first["date_updated_day"]).to be 4 }

      it { expect(result["date_published"]).to be_an(Array) }
      it { expect(result["date_published"].first["date_published_year"]).to be 2021 }
      it { expect(result["date_published"].first["date_published_month"]).to be 1 }
      it { expect(result["date_published"].first["date_published_day"]).to be 1 }

      it { expect(result["contributor"]).to be_an(Array) }
      it { expect(result["contributor"].size).to eq 0 }

      it { expect(result["creator"]).to be_an(Array) }
      it { expect(result["creator"].size).to eq 12 }

      # Just do the first couple as if they work, the rest are fine too as we have the size checked above
      it { expect(result["creator"][0]["creator_name_type"]).to eq "Personal" }
      it { expect(result["creator"][0]["creator_given_name"]).to eq "Palur V" }
      it { expect(result["creator"][0]["creator_family_name"]).to eq "Raghuvamsi" }
      it { expect(result["creator"][0]["creator_orcid"]).to eq "https://orcid.org/0000-0002-0897-6935" }

      it { expect(result["creator"][1]["creator_name_type"]).to eq "Personal" }
      it { expect(result["creator"][1]["creator_given_name"]).to eq "Nikhil K" }
      it { expect(result["creator"][1]["creator_family_name"]).to eq "Tulsian" }
      it { expect(result["creator"][1]["creator_orcid"]).to eq "https://orcid.org/0000-0001-6577-6748" }
    end
  end
end
