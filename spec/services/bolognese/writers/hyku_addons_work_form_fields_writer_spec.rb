# frozen_string_literal: true
require "rails_helper"

RSpec.describe Bolognese::Writers::HykuAddonsWorkFormFieldsWriter do
  describe "#hyku_addons_work" do
    it "responds to the method" do
      expect(Bolognese::Metadata.new).to respond_to(:hyku_addons_work_form_fields)
    end
  end

  # This method is overwritten for the time being so as to fix an issue with how they are validating funder DOIs
  describe "#validate_funder_doi" do
    let(:subject) { Bolognese::Metadata.new }

    it "validates the DOI" do
      expect(subject.send(:validate_funder_doi, "10.13039/501100001711")).to eq "https://doi.org/10.13039/501100001711"
    end

    it "validates the DOI" do
      expect(subject.send(:validate_funder_doi, "501100001711")).to eq "https://doi.org/10.13039/501100001711"
    end

    context "when the DOI is an eLife DOI" do
      it "validates the DOI" do
        expect(subject.send(:validate_funder_doi, "10.13039/100000050")).to eq "https://doi.org/10.13039/100000050"
      end

      it "validates the DOI" do
        expect(subject.send(:validate_funder_doi, "10.13039/100006492")).to eq "https://doi.org/10.13039/100006492"
      end
    end

  end

  context "Hyku Addons Writer" do
    let(:meta) { Bolognese::Metadata.new(input: fixture) }
    let(:result) { meta.hyku_addons_work_form_fields }

    describe "an article" do
      let(:fixture) { File.read Rails.root.join("..", "fixtures", "doi", "10.5334-as.1.xml") }

      it { expect(meta.doi).to be_present }
      it { expect(result).to be_a Hash }

      it { expect(result["publisher"]).to eq ["Ubiquity Press, Ltd."] }
      it { expect(result["title"].first).to include "As Paisagens Sonora, Olfactiva e Culinária em Alice’s" }
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

    describe "a journal doi with multiple complete creators" do
      let(:fixture) { File.read Rails.root.join("..", "fixtures", "doi", '10.7554-elife.63646.xml') }
      let(:json_data) { File.read Rails.root.join("..", "fixtures", "ror", "501100001349.json") }

      before do
        allow_any_instance_of(Faraday::Connection).to receive(:get).and_return(
          double(Faraday::Response, status: 200, body: json_data, success?: true)
        )
      end

      it { expect(meta.doi).to be_present }
      it { expect(result).to be_a Hash }

      it { expect(result["publisher"]).to eq ["eLife Sciences Publications, Ltd"] }
      it { expect(result["title"]).to eq ["SARS-CoV-2 S protein:ACE2 interaction reveals novel allosteric targets"] }
      it { expect(result["doi"]).to eq ["10.7554/elife.63646"] }

      it { expect(result["abstract"].first).to include("The spike (S) protein is the main handle for SARS-CoV-2") }
      it { expect(result["keyword"]).to be_nil }

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

      # As there is only a single funder being mocked, just check that one and ignore the others
      it { expect(result["funder"]).to be_an(Array) }
      it { expect(result["funder"].size).to eq 4 }

      it { expect(result["funder"][0]["funder_name"]).to eq "National Medical Research Council" }
      it { expect(result["funder"][0]["funder_award"].first).to include "WBS#R-571-000-081-213" }
      it { expect(result["funder"][0]["funder_doi"]).to eq "10.13039/501100001349" }
      it { expect(result["funder"][0]["funder_isni"]).to eq "0000 0004 4687 8046" }
      it { expect(result["funder"][0]["funder_fundref"]).to eq "501100001349" }
      it { expect(result["funder"][0]["funder_grid"]).to eq "grid.452975.8" }
      it { expect(result["funder"][0]["funder_ror"]).to eq "https://ror.org/04x3cxs03" }
    end

    describe "a book chapter" do
      let(:fixture) { File.read Rails.root.join("..", "fixtures", "doi", "10.5040-9780755697397.0006.xml") }

      it { expect(meta.doi).to be_present }
      it { expect(result).to be_a Hash }

      it { expect(result["publisher"]).to eq ["Bloomsbury Academic"] }
      it { expect(result["title"]).to eq ["Introduction: Britain, Britain, Little Britain..."] }
      it { expect(result["doi"]).to eq ["10.5040/9780755697397.0006"] }

      it { expect(result["date_published"]).to be_an(Array) }
      it { expect(result["date_published"].first["date_published_year"]).to be 2010 }
      it { expect(result["date_published"].first["date_published_month"]).to be 1 }
      it { expect(result["date_published"].first["date_published_day"]).to be 1 }

      it { expect(result["contributor"]).to be_an(Array) }
      it { expect(result["contributor"].size).to eq 0 }

      it { expect(result["creator"]).to be_an(Array) }
      it { expect(result["creator"].size).to eq 1 }
      it { expect(result["creator"][0]["creator_name_type"]).to eq "Personal" }
      it { expect(result["creator"][0]["creator_given_name"]).to eq "Sharon" }
      it { expect(result["creator"][0]["creator_family_name"]).to eq "Lockyer" }
    end

    describe "a book" do
      let(:fixture) { File.read Rails.root.join("..", "fixtures", "doi", "10.5040-9780755697397.xml") }

      it { expect(meta.doi).to be_present }
      it { expect(result).to be_a Hash }

      it { expect(result["publisher"]).to eq ["Bloomsbury Academic"] }
      it { expect(result["title"]).to eq ["Reading Little Britain"] }
      it { expect(result["doi"]).to eq ["10.5040/9780755697397"] }

      it { expect(result["date_published"]).to be_an(Array) }
      it { expect(result["date_published"].first["date_published_year"]).to be 2010 }
      it { expect(result["date_published"].first["date_published_month"]).to be 1 }
      it { expect(result["date_published"].first["date_published_day"]).to be 1 }

      it { expect(result["contributor"]).to be_an(Array) }
      it { expect(result["contributor"].size).to eq 1 }
      it { expect(result["contributor"][0]["contributor_name_type"]).to eq "Personal" }
      it { expect(result["contributor"][0]["contributor_given_name"]).to eq "Sharon" }
      it { expect(result["contributor"][0]["contributor_family_name"]).to eq "Lockyer" }

      it { expect(result["creator"]).to be_an(Array) }
      it { expect(result["creator"].size).to eq 1 }
      it { expect(result["creator"][0]["creator_name_type"]).to eq "Organizational" }
      it { expect(result["creator"][0]["creator_name"]).to eq ":(unav)" }
    end

    describe "a report" do
      let(:fixture) { File.read Rails.root.join("..", "fixtures", "doi", "10.1920-bn.ifs.2003.0038.xml") }

      it { expect(meta.doi).to be_present }
      it { expect(result).to be_a Hash }

      it { expect(result["publisher"]).to eq ["Institute for Fiscal Studies"] }
      it { expect(result["title"]).to eq ["Is middle Britain middle-income Britain?"] }
      it { expect(result["doi"]).to eq ["10.1920/bn.ifs.2003.0038"] }

      it { expect(result["date_published"]).to be_an(Array) }
      it { expect(result["date_published"].first["date_published_year"]).to be 2003 }
      it { expect(result["date_published"].first["date_published_month"]).to be 1 }
      it { expect(result["date_published"].first["date_published_day"]).to be 1 }

      it { expect(result["contributor"]).to be_an(Array) }
      it { expect(result["contributor"].size).to eq 0 }

      it { expect(result["creator"]).to be_an(Array) }
      it { expect(result["creator"].size).to eq 1 }
      it { expect(result["creator"][0]["creator_name_type"]).to eq "Personal" }
      it { expect(result["creator"][0]["creator_given_name"]).to eq "Matthew" }
      it { expect(result["creator"][0]["creator_family_name"]).to eq "Wakefield" }
    end

    describe "a blog post" do
      let(:fixture) { File.read Rails.root.join("..", "fixtures", "doi", "10.18785-fa.m165.xml") }

      it { expect(meta.doi).to be_present }
      it { expect(result).to be_a Hash }

      it { expect(result["publisher"]).to eq ["University of Southern Mississippi"] }
      it { expect(result["title"]).to eq ["Great Britain Parliament"] }
      it { expect(result["doi"]).to eq ["10.18785/fa.m165"] }

      it { expect(result["date_published"]).to be_an(Array) }
      it { expect(result["date_published"].first["date_published_year"]).to be 2017 }
      it { expect(result["date_published"].first["date_published_month"]).to be 1 }
      it { expect(result["date_published"].first["date_published_day"]).to be 1 }

      it { expect(result["contributor"]).to be_an(Array) }
      it { expect(result["contributor"].size).to eq 0 }

      it { expect(result["creator"]).to be_an(Array) }
      it { expect(result["creator"].size).to eq 1 }
      it { expect(result["creator"][0]["creator_name_type"]).to eq "Personal" }
      it { expect(result["creator"][0]["creator_given_name"]).to eq "Special Collections, University Libraries" }
      it { expect(result["creator"][0]["creator_family_name"]).to eq "University of Southern Mississippi" }
    end

    describe "a journal article" do
      let(:fixture) { File.read Rails.root.join("..", "fixtures", "doi", "10.1080-14714787.2012.641791.xml") }

      it { expect(meta.doi).to be_present }
      it { expect(result).to be_a Hash }

      it { expect(result["publisher"]).to eq ["Informa UK Limited"] }
      it { expect(result["title"]).to eq ["Cinema, Colour and the Festival of Britain, 1951"] }
      it { expect(result["doi"]).to eq ["10.1080/14714787.2012.641791"] }

      it { expect(result["date_published"]).to be_an(Array) }
      it { expect(result["date_published"].first["date_published_year"]).to be 2012 }
      it { expect(result["date_published"].first["date_published_month"]).to be 1 }
      it { expect(result["date_published"].first["date_published_day"]).to be 1 }

      it { expect(result["contributor"]).to be_an(Array) }
      it { expect(result["contributor"].size).to eq 0 }

      it { expect(result["creator"]).to be_an(Array) }
      it { expect(result["creator"].size).to eq 1 }
      it { expect(result["creator"][0]["creator_name_type"]).to eq "Personal" }
      it { expect(result["creator"][0]["creator_given_name"]).to eq "Sarah" }
      it { expect(result["creator"][0]["creator_family_name"]).to eq "Street" }
    end

    describe "a dataset post" do
      let(:fixture) { File.read Rails.root.join("..", "fixtures", "doi", "10.7925-drs1.duchas_5019334.xml") }

      it { expect(meta.doi).to be_present }
      it { expect(result).to be_a Hash }

      it { expect(result["publisher"]).to eq ["National Folklore Collection, University College Dublin"] }
      it { expect(result["title"]).to eq ["Witchcraft"] }
      it { expect(result["doi"]).to eq ["10.7925/drs1.duchas_5019334"] }
      it { expect(result["abstract"].first).to include("Story collected by William Morris") }
      it { expect(result["keyword"]).to eq ["diviners", "Soothsayers", "Lucht feasa"] }

      it { expect(result["date_published"]).to be_an(Array) }
      it { expect(result["date_published"].first["date_published_year"]).to be 2017 }
      it { expect(result["date_published"].first["date_published_month"]).to be 1 }
      it { expect(result["date_published"].first["date_published_day"]).to be 1 }

      it { expect(result["contributor"]).to be_an(Array) }

      # This seems wierd, as 3 are normal contributors, but 3 are Funders
      # The DOI appears to be incorrectly formatted, however this does give us some edge cases to account for
      it { expect(result["contributor"].size).to eq 6 }

      it { expect(result["contributor"][0]["contributor_name_type"]).to eq "Personal" }
      it { expect(result["contributor"][0]["contributor_given_name"]).to eq "Gan Ainm / Mícheál Ó" }
      it { expect(result["contributor"][0]["contributor_family_name"]).to eq "Séaghdha" }

      it { expect(result["contributor"][1]["contributor_name_type"]).to eq "Personal" }
      it { expect(result["contributor"][1]["contributor_given_name"]).to eq "William" }
      it { expect(result["contributor"][1]["contributor_family_name"]).to eq "Morris" }

      it { expect(result["contributor"][2]["contributor_name_type"]).to eq "Personal" }
      it { expect(result["contributor"][2]["contributor_given_name"]).to eq "William" }
      it { expect(result["contributor"][2]["contributor_family_name"]).to eq "Morris" }

      it { expect(result["creator"]).to be_an(Array) }
      it { expect(result["creator"].size).to eq 3 }

      it { expect(result["creator"][0]["creator_name_type"]).to eq "Personal" }
      it { expect(result["creator"][0]["creator_given_name"]).to eq "Gan Ainm / Mícheál Ó" }
      it { expect(result["creator"][0]["creator_family_name"]).to eq "Séaghdha" }

      it { expect(result["creator"][1]["creator_name_type"]).to eq "Personal" }
      it { expect(result["creator"][1]["creator_given_name"]).to eq "William" }
      it { expect(result["creator"][1]["creator_family_name"]).to eq "Morris" }

      it { expect(result["creator"][2]["creator_name_type"]).to eq "Personal" }
      it { expect(result["creator"][2]["creator_given_name"]).to eq "William" }
      it { expect(result["creator"][2]["creator_family_name"]).to eq "Morris" }
    end

    describe "a data set with funder information" do
      let(:fixture) { File.read Rails.root.join("..", "fixtures", "doi", "10.23636-1345.xml") }
      let(:json_data) { File.read Rails.root.join("..", "fixtures", "ror", "501100000267.json") }

      before do
        allow_any_instance_of(Faraday::Connection).to receive(:get).and_return(
          double(Faraday::Response, status: 200, body: json_data, success?: true)
        )
      end

      it { expect(meta.doi).to be_present }
      it { expect(result).to be_a Hash }

      it { expect(result["publisher"]).to eq ["British Library"] }
      it { expect(result["title"]).to eq ["Catalogue records of photographs (1850-1950)"] }
      it { expect(result["doi"]).to eq ["10.23636/1345"] }
      it { expect(result["keyword"]).to eq ["photographs", "datasets", "metadata", "catalogues"] }

      it { expect(result["date_published"]).to be_an(Array) }
      it { expect(result["date_published"].first["date_published_year"]).to be 2021 }
      it { expect(result["date_published"].first["date_published_month"]).to be 1 }
      it { expect(result["date_published"].first["date_published_day"]).to be 1 }

      it { expect(result["contributor"]).to be_an(Array) }
      it { expect(result["contributor"].size).to eq 2 }

      it { expect(result["contributor"][0]["contributor_name_type"]).to eq "Personal" }
      it { expect(result["contributor"][0]["contributor_given_name"]).to eq "Rossitza" }
      it { expect(result["contributor"][0]["contributor_family_name"]).to eq "Atanassova" }
      it { expect(result["contributor"][0]["contributor_isni"]).to eq "http://isni.org/isni/0000000048095185" }
      it { expect(result["contributor"][0]["contributor_orcid"]).to eq "https://orcid.org/0000-0003-4005-2668" }

      it { expect(result["contributor"][1]["contributor_name_type"]).to eq "Personal" }
      it { expect(result["contributor"][1]["contributor_given_name"]).to eq "James" }
      it { expect(result["contributor"][1]["contributor_family_name"]).to eq "Baker" }
      it { expect(result["contributor"][1]["contributor_isni"]).to eq "http://isni.org/isni/0000000427103560" }
      it { expect(result["contributor"][1]["contributor_orcid"]).to eq "https://orcid.org/0000-0002-2682-6922" }

      it { expect(result["creator"]).to be_an(Array) }
      it { expect(result["creator"].size).to eq 2 }

      it { expect(result["creator"][0]["creator_name_type"]).to eq "Organizational" }
      it { expect(result["creator"][0]["creator_name"]).to eq "British Library" }
      it { expect(result["creator"][0]["creator_isni"]).to eq "http://isni.org/isni/0000000123081542" }

      it { expect(result["creator"][1]["creator_name_type"]).to eq "Personal" }
      it { expect(result["creator"][1]["creator_given_name"]).to eq "Nicolas" }
      it { expect(result["creator"][1]["creator_family_name"]).to eq "Moretto" }

      it { expect(result["funder"]).to be_an(Array) }
      it { expect(result["funder"].size).to eq 1 }

      it { expect(result["funder"][0]["funder_name"]).to eq "Arts and Humanities Research Council" }
      it { expect(result["funder"][0]["funder_award"]).to eq ["AH/T013036/1"] }
      it { expect(result["funder"][0]["funder_doi"]).to eq "10.13039/501100000267" }
      it { expect(result["funder"][0]["funder_isni"]).to eq "0000 0004 3497 6001" }
      it { expect(result["funder"][0]["funder_fundref"]).to eq "501100007818" }
      it { expect(result["funder"][0]["funder_wikidata"]).to eq "Q4801497" }
      it { expect(result["funder"][0]["funder_grid"]).to eq "grid.426413.6" }
      it { expect(result["funder"][0]["funder_ror"]).to eq "https://ror.org/0505m1554" }
    end
  end
end
