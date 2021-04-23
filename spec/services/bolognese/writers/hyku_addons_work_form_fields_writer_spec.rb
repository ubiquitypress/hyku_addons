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
    let(:meta) { Bolognese::Metadata.new }

    it "validates for an expected DOI" do
      expect(meta.send(:validate_funder_doi, "10.13039/501100001711")).to eq "https://doi.org/10.13039/501100001711"
    end

    it "validates for an expected DOI suffix" do
      expect(meta.send(:validate_funder_doi, "501100001711")).to eq "https://doi.org/10.13039/501100001711"
    end

    context "when the DOI is an eLife DOI" do
      it "validates a new DOI" do
        expect(meta.send(:validate_funder_doi, "10.13039/100000050")).to eq "https://doi.org/10.13039/100000050"
      end

      it "validates another new DOI" do
        expect(meta.send(:validate_funder_doi, "10.13039/100006492")).to eq "https://doi.org/10.13039/100006492"
      end
    end
  end

  context "Hyku Addons Writer" do
    let(:faraday_headers) do
      {
        'Accept' => '*/*',
        'Accept-Encoding' => 'gzip;q=1.0,deflate;q=0.6,identity;q=0.3',
        'User-Agent' => 'Faraday v0.17.4'
      }
    end
    let(:meta) { Bolognese::Metadata.new(input: fixture) }
    let(:result) { meta.hyku_addons_work_form_fields }

    describe "an article" do
      let(:fixture) { File.read Rails.root.join("..", "fixtures", "doi", "10.5334-as.1.xml") }

      it { expect(meta.doi).to be_present }
      it { expect(result).to be_a Hash }

      it { expect(result["publisher"]).to eq ["Ubiquity Press, Ltd."] }
      it { expect(result["title"].first).to include "As Paisagens Sonora, Olfactiva e Culinária em Alice’s" }
      it { expect(result["doi"]).to eq ["10.5334/as.1"] }
      it { expect(result["license"]).to eq ["https://creativecommons.org/licenses/by/4.0/"] }

      it { expect(result["date_published"]).to be_an(Array) }
      it { expect(result["date_published"].first["date_published_year"]).to be 2020 }
      it { expect(result["date_published"].first["date_published_month"]).to be 2 }
      it { expect(result["date_published"].first["date_published_day"]).to be 14 }

      it { expect(result["creator"]).to be_an(Array) }
      it { expect(result["creator"].first["creator_given_name"]).to eq "Rogério Miguel" }
      it { expect(result["creator"].first["creator_family_name"]).to eq "Puga" }
    end

    describe "a journal doi with multiple complete creators" do
      let(:fixture) { File.read Rails.root.join("..", "fixtures", "doi", '10.7554-elife.63646.xml') }
      let(:json_501100001349) { File.read Rails.root.join("..", "fixtures", "ror", "501100001349.json") }
      let(:json_501100001441) { File.read Rails.root.join("..", "fixtures", "ror", "501100001441.json") }
      let(:json_501100001352) { File.read Rails.root.join("..", "fixtures", "ror", "501100001352.json") }
      let(:json_501100001459) { File.read Rails.root.join("..", "fixtures", "ror", "501100001459.json") }

      before do
        stub_request(:get, "https://api.ror.org/organizations?query=501100001349")
          .with(headers: faraday_headers)
          .to_return(status: 200, body: json_501100001349, headers: {})

        stub_request(:get, "https://api.ror.org/organizations?query=501100001441")
          .with(headers: faraday_headers)
          .to_return(status: 200, body: json_501100001441, headers: {})

        stub_request(:get, "https://api.ror.org/organizations?query=501100001352")
          .with(headers: faraday_headers)
          .to_return(status: 200, body: json_501100001352, headers: {})

        stub_request(:get, "https://api.ror.org/organizations?query=501100001459")
          .with(headers: faraday_headers)
          .to_return(status: 200, body: json_501100001459, headers: {})
      end

      it { expect(meta.doi).to be_present }
      it { expect(result).to be_a Hash }

      it { expect(result["publisher"]).to eq ["eLife Sciences Publications, Ltd"] }
      it { expect(result["title"]).to eq ["SARS-CoV-2 S protein:ACE2 interaction reveals novel allosteric targets"] }
      it { expect(result["doi"]).to eq ["10.7554/elife.63646"] }
      it { expect(result["license"]).to eq ["https://creativecommons.org/licenses/by/4.0/"] }

      it { expect(result["abstract"].first).to include("The spike (S) protein is the main handle for SARS-CoV-2") }
      it { expect(result["journal_title"]).to eq ["eLife"] }
      it { expect(result["keyword"]).to be_nil }

      it { expect(result["date_published"]).to be_an(Array) }
      it { expect(result["date_published"].first["date_published_year"]).to be 2021 }
      it { expect(result["date_published"].first["date_published_month"]).to be 2 }
      it { expect(result["date_published"].first["date_published_day"]).to be 8 }

      it { expect(result["contributor"]).to be_nil }

      it { expect(result["creator"]).to be_an(Array) }
      it { expect(result["creator"].size).to eq 12 }

      it { expect(result["creator"][0]["creator_name_type"]).to eq "Personal" }
      it { expect(result["creator"][0]["creator_given_name"]).to eq "Palur V" }
      it { expect(result["creator"][0]["creator_family_name"]).to eq "Raghuvamsi" }
      it { expect(result["creator"][0]["creator_orcid"]).to eq "https://orcid.org/0000-0002-0897-6935" }

      it { expect(result["creator"][1]["creator_name_type"]).to eq "Personal" }
      it { expect(result["creator"][1]["creator_given_name"]).to eq "Nikhil K" }
      it { expect(result["creator"][1]["creator_family_name"]).to eq "Tulsian" }
      it { expect(result["creator"][1]["creator_orcid"]).to eq "https://orcid.org/0000-0001-6577-6748" }

      it { expect(result["creator"][2]["creator_name_type"]).to eq "Personal" }
      it { expect(result["creator"][2]["creator_given_name"]).to eq "Firdaus" }
      it { expect(result["creator"][2]["creator_family_name"]).to eq "Samsudin" }
      it { expect(result["creator"][2]["creator_orcid"]).to be_nil }

      it { expect(result["creator"][3]["creator_name_type"]).to eq "Personal" }
      it { expect(result["creator"][3]["creator_given_name"]).to eq "Xinlei" }
      it { expect(result["creator"][3]["creator_family_name"]).to eq "Qian" }
      it { expect(result["creator"][3]["creator_orcid"]).to be_nil }

      it { expect(result["creator"][4]["creator_name_type"]).to eq "Personal" }
      it { expect(result["creator"][4]["creator_given_name"]).to eq "Kiren" }
      it { expect(result["creator"][4]["creator_family_name"]).to eq "Purushotorman" }
      it { expect(result["creator"][4]["creator_orcid"]).to be_nil }

      it { expect(result["creator"][5]["creator_name_type"]).to eq "Personal" }
      it { expect(result["creator"][5]["creator_given_name"]).to eq "Gu" }
      it { expect(result["creator"][5]["creator_family_name"]).to eq "Yue" }
      it { expect(result["creator"][5]["creator_orcid"]).to be_nil }

      it { expect(result["creator"][6]["creator_name_type"]).to eq "Personal" }
      it { expect(result["creator"][6]["creator_given_name"]).to eq "Mary M" }
      it { expect(result["creator"][6]["creator_family_name"]).to eq "Kozma" }
      it { expect(result["creator"][6]["creator_orcid"]).to be_nil }

      it { expect(result["creator"][7]["creator_name_type"]).to eq "Personal" }
      it { expect(result["creator"][7]["creator_given_name"]).to eq "Wong Y" }
      it { expect(result["creator"][7]["creator_family_name"]).to eq "Hwa" }
      it { expect(result["creator"][7]["creator_orcid"]).to be_nil }

      it { expect(result["creator"][8]["creator_name_type"]).to eq "Personal" }
      it { expect(result["creator"][8]["creator_given_name"]).to eq "Julien" }
      it { expect(result["creator"][8]["creator_family_name"]).to eq "Lescar" }
      it { expect(result["creator"][8]["creator_orcid"]).to be_nil }

      it { expect(result["creator"][9]["creator_name_type"]).to eq "Personal" }
      it { expect(result["creator"][9]["creator_given_name"]).to eq "Peter J" }
      it { expect(result["creator"][9]["creator_family_name"]).to eq "Bond" }
      it { expect(result["creator"][9]["creator_orcid"]).to eq "https://orcid.org/0000-0003-2900-098X" }

      it { expect(result["creator"][10]["creator_name_type"]).to eq "Personal" }
      it { expect(result["creator"][10]["creator_given_name"]).to eq "Paul A" }
      it { expect(result["creator"][10]["creator_family_name"]).to eq "MacAry" }
      it { expect(result["creator"][10]["creator_orcid"]).to be_nil }

      it { expect(result["creator"][11]["creator_name_type"]).to eq "Personal" }
      it { expect(result["creator"][11]["creator_given_name"]).to eq "Ganesh S" }
      it { expect(result["creator"][11]["creator_family_name"]).to eq "Anand" }
      it { expect(result["creator"][11]["creator_orcid"]).to eq "https://orcid.org/0000-0001-8995-3067" }

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
      it { expect(result["license"]).to be_nil }

      it { expect(result["date_published"]).to be_an(Array) }
      it { expect(result["date_published"].first["date_published_year"]).to be 2010 }
      it { expect(result["date_published"].first["date_published_month"]).to be 1 }
      it { expect(result["date_published"].first["date_published_day"]).to be 1 }

      it { expect(result["contributor"]).to be_nil }

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
      it { expect(result["license"]).to be_nil }

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
      it { expect(result["license"]).to be_nil }

      it { expect(result["date_published"]).to be_an(Array) }
      it { expect(result["date_published"].first["date_published_year"]).to be 2003 }
      it { expect(result["date_published"].first["date_published_month"]).to be 9 }
      it { expect(result["date_published"].first["date_published_day"]).to be 1 }

      it { expect(result["contributor"]).to be_nil }

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
      it { expect(result["license"]).to be_nil }

      it { expect(result["date_published"]).to be_an(Array) }
      it { expect(result["date_published"].first["date_published_year"]).to be 2017 }
      it { expect(result["date_published"].first["date_published_month"]).to be 4 }
      it { expect(result["date_published"].first["date_published_day"]).to be 17 }

      it { expect(result["contributor"]).to be_nil }

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
      it { expect(result["license"]).to be_nil }

      it { expect(result["date_published"]).to be_an(Array) }
      it { expect(result["date_published"].first["date_published_year"]).to be 2012 }
      it { expect(result["date_published"].first["date_published_month"]).to be 3 }
      it { expect(result["date_published"].first["date_published_day"]).to be 1 }

      it { expect(result["contributor"]).to be_nil }

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
      it { expect(result["official_link"]).to eq ["https//doi.org/10.7925/drs1.duchas_5019334"] }
      it { expect(result["language"]).to eq ["en"] }

      it { expect(result["license"].count).to eq 3 }
      it { expect(result["license"]).to include("https://creativecommons.org/licenses/by-nc/4.0/") }

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
        allow(Faraday).to receive(:get).and_return(
          instance_double(Faraday::Response, status: 200, body: json_data, success?: true)
        )
      end

      it { expect(meta.doi).to be_present }
      it { expect(result).to be_a Hash }

      it { expect(result["publisher"]).to eq ["British Library"] }
      it { expect(result["title"]).to eq ["Catalogue records of photographs (1850-1950)"] }
      it { expect(result["doi"]).to eq ["10.23636/1345"] }
      it { expect(result["keyword"]).to eq ["photographs", "datasets", "metadata", "catalogues"] }
      it { expect(result["license"]).to eq ["https://creativecommons.org/publicdomain/zero/1.0/"] }

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

    describe "a Journal Article" do
      let(:fixture) { File.read Rails.root.join("..", "fixtures", "doi", "10.7554-elife.47972.xml") }
      let(:json_100000065) { File.read Rails.root.join("..", "fixtures", "ror", "100000065.json") }
      let(:json_100000026) { File.read Rails.root.join("..", "fixtures", "ror", "100000026.json") }
      let(:json_100006691) { File.read Rails.root.join("..", "fixtures", "ror", "100006691.json") }

      before do
        stub_request(:get, "https://api.ror.org/organizations?query=100000026")
          .with(headers: faraday_headers)
          .to_return(status: 200, body: json_100000026, headers: {})

        stub_request(:get, "https://api.ror.org/organizations?query=100000065")
          .with(headers: faraday_headers)
          .to_return(status: 200, body: json_100000065, headers: {})

        stub_request(:get, "https://api.ror.org/organizations?query=100006691")
          .with(headers: faraday_headers)
          .to_return(status: 200, body: json_100006691, headers: {})
      end

      it { expect(meta.doi).to be_present }
      it { expect(result).to be_a Hash }

      it { expect(result["publisher"]).to eq ["eLife Sciences Publications, Ltd"] }
      it { expect(result["doi"]).to include("10.7554/elife.47972") }

      title = "RIM is essential for stimulated but not spontaneous somatodendritic dopamine release in the midbrain"
      it { expect(result["title"]).to eq [title] }

      it { expect(result["abstract"].first).to include("Action potentials trigger neurotransmitter") }
      it { expect(result["volume"]).to eq "8" }
      it { expect(result["official_link"]).to eq ["https://elifesciences.org/articles/47972"] }
      it { expect(result["issn"]).to eq ["2050-084X"] }
      it { expect(result["journal_title"]).to eq ["eLife"] }

      it { expect(result["keyword"]).to be_nil }

      it { expect(result["date_published"]).to be_an(Array) }
      it { expect(result["date_published"].first["date_published_year"]).to be 2019 }
      it { expect(result["date_published"].first["date_published_month"]).to be 9 }
      it { expect(result["date_published"].first["date_published_day"]).to be 5 }

      it { expect(result["contributor"]).to be_nil }

      it { expect(result["creator"]).to be_an(Array) }
      it { expect(result["creator"].size).to eq 6 }

      it { expect(result["creator"][0]["creator_name_type"]).to eq "Personal" }
      it { expect(result["creator"][0]["creator_given_name"]).to eq "Brooks G" }
      it { expect(result["creator"][0]["creator_family_name"]).to eq "Robinson" }
      it { expect(result["creator"][0]["creator_orcid"]).to eq "https://orcid.org/0000-0001-5020-531X" }

      it { expect(result["creator"][1]["creator_name_type"]).to eq "Personal" }
      it { expect(result["creator"][1]["creator_given_name"]).to eq "Xintong" }
      it { expect(result["creator"][1]["creator_family_name"]).to eq "Cai" }
      it { expect(result["creator"][1]["creator_orcid"]).to be_nil }

      it { expect(result["creator"][2]["creator_name_type"]).to eq "Personal" }
      it { expect(result["creator"][2]["creator_given_name"]).to eq "Jiexin" }
      it { expect(result["creator"][2]["creator_family_name"]).to eq "Wang" }
      it { expect(result["creator"][2]["creator_orcid"]).to be_nil }

      it { expect(result["creator"][3]["creator_name_type"]).to eq "Personal" }
      it { expect(result["creator"][3]["creator_given_name"]).to eq "James R" }
      it { expect(result["creator"][3]["creator_family_name"]).to eq "Bunzow" }
      it { expect(result["creator"][3]["creator_orcid"]).to be_nil }

      it { expect(result["creator"][4]["creator_name_type"]).to eq "Personal" }
      it { expect(result["creator"][4]["creator_given_name"]).to eq "John T" }
      it { expect(result["creator"][4]["creator_family_name"]).to eq "Williams" }
      it { expect(result["creator"][4]["creator_orcid"]).to eq "https://orcid.org/0000-0002-0647-6144" }

      it { expect(result["creator"][5]["creator_name_type"]).to eq "Personal" }
      it { expect(result["creator"][5]["creator_given_name"]).to eq "Pascal S" }
      it { expect(result["creator"][5]["creator_family_name"]).to eq "Kaeser" }
      it { expect(result["creator"][5]["creator_orcid"]).to eq "https://orcid.org/0000-0002-1558-1958" }

      it { expect(result["funder"]).to be_an(Array) }
      it { expect(result["funder"].size).to eq 3 }

      it { expect(result["funder"][0]["funder_name"]).to eq "National Institute of Neurological Disorders and Stroke" }
      it { expect(result["funder"][0]["funder_doi"]).to eq "10.13039/100000065" }
      it { expect(result["funder"][0]["funder_award"]).to eq ["R01NS083898", "R01NS103484"] }
      it { expect(result["funder"][0]["funder_isni"]).to eq "0000 0001 2177 357X" }
      it { expect(result["funder"][0]["funder_fundref"]).to eq "100000065" }
      it { expect(result["funder"][0]["funder_grid"]).to eq "grid.416870.c" }
      it { expect(result["funder"][0]["funder_ror"]).to eq "https://ror.org/01s5ya894" }

      it { expect(result["funder"][1]["funder_name"]).to eq "National Institute on Drug Abuse" }
      it { expect(result["funder"][1]["funder_doi"]).to eq "10.13039/100000026" }
      it { expect(result["funder"][1]["funder_award"]).to eq ["R01DA04523", "K99DA044287"] }
      it { expect(result["funder"][1]["funder_isni"]).to eq "0000 0004 0533 7147" }
      it { expect(result["funder"][1]["funder_fundref"]).to eq "100000026" }
      it { expect(result["funder"][1]["funder_grid"]).to eq "grid.420090.f" }
      it { expect(result["funder"][1]["funder_ror"]).to eq "https://ror.org/00fq5cm18" }

      it { expect(result["funder"][2]["funder_name"]).to eq "Harvard Medical School" }
      it { expect(result["funder"][2]["funder_doi"]).to eq "10.13039/100006691" }
      it { expect(result["funder"][2]["funder_award"]).to eq [] }
      it { expect(result["funder"][2]["funder_isni"]).to eq "000000041936754X" }
      it { expect(result["funder"][2]["funder_fundref"]).to eq "100007229" }
      it { expect(result["funder"][2]["funder_grid"]).to eq "grid.38142.3c" }
      it { expect(result["funder"][2]["funder_ror"]).to eq "https://ror.org/03vek6s52" }

      it { expect(result["license"]).to be_an(Array) }
      it { expect(result["license"].count).to be 1 }
      it { expect(result["license"]).to eq ["https://creativecommons.org/licenses/by/4.0/"] }
    end

    describe "a book with an isbn" do
      let(:fixture) { File.read Rails.root.join("..", "fixtures", "doi", "10.11647-obp.0232.xml") }

      it { expect(meta.doi).to be_present }
      it { expect(result).to be_a Hash }

      it { expect(result["doi"]).to include("10.11647/obp.0232") }
      it { expect(result["title"]).to eq ["Romanticism and Time"] }
      it { expect(result["publisher"]).to eq ["Open Book Publishers"] }
      it { expect(result["abstract"]).to be_nil }
      it { expect(result["volume"]).to be_nil }
      it { expect(result["official_link"]).to eq ["https://www.openbookpublishers.com/product/1254"] }
      it { expect(result["issn"]).to be_nil }
      it { expect(result["isbn"]).to eq ["978-1-80064-071-9"] }
      it { expect(result["keyword"]).to be_nil }
      it { expect(result["journal_title"]).to be_nil }

      it { expect(result["date_published"]).to be_an(Array) }
      it { expect(result["date_published"].first["date_published_year"]).to be 2021 }
      it { expect(result["date_published"].first["date_published_month"]).to be 3 }
      it { expect(result["date_published"].first["date_published_day"]).to be 1 }

      it { expect(result["contributor"]).to be_an(Array) }
      it { expect(result["contributor"].size).to eq 2 }

      it { expect(result["contributor"][0]["contributor_name_type"]).to eq "Personal" }
      it { expect(result["contributor"][0]["contributor_given_name"]).to eq "Sophie" }
      it { expect(result["contributor"][0]["contributor_family_name"]).to eq "Laniel-Musitelli" }
      it { expect(result["contributor"][0]["contributor_orcid"]).to eq "https://orcid.org/0000-0001-6622-9455" }
      it { expect(result["contributor"][0]["contributor_contributor_type"]).to eq "Editor" }

      it { expect(result["contributor"][1]["contributor_name_type"]).to eq "Personal" }
      it { expect(result["contributor"][1]["contributor_given_name"]).to eq "Céline" }
      it { expect(result["contributor"][1]["contributor_family_name"]).to eq "Sabiron" }
      it { expect(result["contributor"][1]["contributor_orcid"]).to be_nil }
      it { expect(result["contributor"][1]["contributor_contributor_type"]).to eq "Editor" }

      it { expect(result["creator"]).to eq [{ "creator_name" => ":(unav)", "creator_name_type" => "Organizational" }] }
    end

    describe "a book chapter" do
      let(:fixture) { File.read Rails.root.join("..", "fixtures", "doi", "10.5334-bbc.b.xml") }

      it { expect(meta.doi).to be_present }
      it { expect(result).to be_a Hash }

      it { expect(result["doi"]).to include("10.5334/bbc.b") }
      it { expect(result["title"]).to eq ["A Brief History of Open Educational Resources"] }

      book_title = "Open: The Philosophy and Practices that are Revolutionizing Education and Science"
      it { expect(result["book_title"]).to eq [book_title] }
      it { expect(result["publisher"]).to eq ["Ubiquity Press, Ltd."] }
      it { expect(result["abstract"]).to be_nil }
      it { expect(result["volume"]).to be_nil }
      it { expect(result["official_link"]).to eq ["http://www.ubiquitypress.com/site/chapters/10.5334/bbc.b/"] }
      it { expect(result["issn"]).to be_nil }
      it { expect(result["isbn"]).to eq ["9781911529002"] }
      it { expect(result["keyword"]).to be_nil }
      it { expect(result["journal_title"]).to be_nil }
      it { expect(result["pagination"]).to eq ["9-27"] }

      it { expect(result["date_published"]).to be_an(Array) }
      it { expect(result["date_published"].first["date_published_year"]).to be 2017 }
      it { expect(result["date_published"].first["date_published_month"]).to be 3 }
      it { expect(result["date_published"].first["date_published_day"]).to be 27 }

      it { expect(result["creator"]).to be_an(Array) }
      it { expect(result["creator"].size).to eq 4 }

      it { expect(result["creator"][0]["creator_name_type"]).to eq "Personal" }
      it { expect(result["creator"][0]["creator_given_name"]).to eq "T.J." }
      it { expect(result["creator"][0]["creator_family_name"]).to eq "Bliss" }
      it { expect(result["creator"][0]["creator_orcid"]).to be_nil }

      it { expect(result["creator"][1]["creator_name_type"]).to eq "Personal" }
      it { expect(result["creator"][1]["creator_given_name"]).to eq "M." }
      it { expect(result["creator"][1]["creator_family_name"]).to eq "Smith" }
      it { expect(result["creator"][1]["creator_orcid"]).to be_nil }

      it { expect(result["creator"][2]["creator_name_type"]).to eq "Organizational" }
      it { expect(result["creator"][2]["creator_name"]).to eq "Hewlett Foundation" }

      it { expect(result["creator"][3]["creator_name_type"]).to eq "Organizational" }
      it { expect(result["creator"][3]["creator_name"]).to eq "Hewlett Foundation" }
    end
  end
end
