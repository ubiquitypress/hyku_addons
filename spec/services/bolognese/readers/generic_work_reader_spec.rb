# frozen_string_literal: true
require "rails_helper"

RSpec.describe Bolognese::Readers::GenericWorkReader do
  let(:abstract) { "Swedish comic about the adventures of the residents of Moominvalley." }
  let(:add_info) { "Nothing to report" }
  let(:alt_title1) { "alt-title" }
  let(:alt_title2) { "alt-title-2" }
  let(:book_title) { "Book Title 1" }
  let(:contributor) { "Elizabeth Portch" }
  let(:created_year) { "1945" }
  let(:creator1_first_name) { "Sebastian" }
  let(:creator1_last_name) { "Hageneuer" }
  let(:creator2_first_name) { "Johnny" }
  let(:creator2_last_name) { "Testing" }
  let(:creator1_orcid) { "https://sandbox.orcid.org/0000-0003-0652-4625" }
  let(:creator1) do
    {
      creator_name_type: "Personal",
      creator_given_name: creator1_first_name,
      creator_family_name: creator1_last_name,
      creator_orcid: creator1_orcid
    }
  end
  let(:creator2) do
    {
      creator_name_type: "Personal",
      creator_given_name: creator2_first_name,
      creator_family_name: creator2_last_name
    }
  end
  let(:date_accepted) { "2018-01-02" }
  let(:date_created) { "#{created_year}-01-01" }
  let(:date_published) { "#{published_year}-01-01" }
  let(:date_submitted) { "2019-01-02" }
  let(:doi) { "10.18130/v3-k4an-w022" }
  let(:duration1) { "duration1" }
  let(:duration2) { "duration2" }
  let(:edition) { "1" }
  let(:editor) { "Test Editor" }
  let(:eissn) { "1234-5678" }
  let(:institution1) { "British Library" }
  let(:institution2) { "British Museum" }
  let(:isbn) { "9781770460621" }
  let(:issn) { "0987654321" }
  let(:issue) { "6" }
  let(:issue) { 7 }
  let(:journal_title) { "Test Journal Title" }
  let(:keyword) { "Lighthouses" }
  let(:keyword2) { "Hippos" }
  let(:language) { "Swedish" }
  let(:language2) { "English" }
  let(:official_link) { "http://test-url.com" }
  let(:org_unit1) { "Department of Crackers" }
  let(:org_unit2) { "Department2" }
  let(:pagination) { "1-2" }
  let(:place_of_publication) { "Finland" }
  let(:place_of_publication1) { "Buenos Aires, Argentina" }
  let(:place_of_publication2) { "Place of publication2" }
  let(:project_name1) { "Project name2" }
  let(:project_name2) { "The Chicken projectca" }
  let(:published_year) { "1946" }
  let(:publisher) { "Schildts" }
  let(:resource_type) { "Book" }
  let(:ris_resource_type_identifier) { "BOOK" }
  let(:series_name) { "Series name" }
  let(:title) { "Moomin" }
  let(:version_number) { "3" }
  let(:volume) { 2 }

  let(:attributes) do
    {
      doi: [doi],
      title: [title],
      alt_title: [alt_title1],
      resource_type: [resource_type],
      creator: [[creator1].to_json],
      contributor: [contributor],
      publisher: [publisher],
      abstract: abstract,
      keyword: [keyword],
      date_created: [date_created],
      date_published: date_published,
      editor: [editor],
      isbn: isbn,
      place_of_publication: [place_of_publication],
      journal_title: journal_title,
      language: [language],
      add_info: add_info,
      issue: issue,
      official_link: official_link,
      volume: [volume]
    }
  end

  let(:model_class) { GenericWork }
  let(:work) { model_class.new(attributes) }
  let(:input) { work.attributes.merge(has_model: work.has_model.first).to_json }
  let(:metadata) { described_class.new(input: input, from: "work") }

  it "reads a GenericWork" do
    expect(metadata).to be_a(Bolognese::Metadata)
  end

  describe "#read_work" do
    it "responds to the method" do
      expect(metadata).to respond_to(:read_work)
    end
  end

  context "crosswalks" do
    context "RIS" do
      describe "a simple work" do
        it "correctly populates the export" do
          ris = metadata.ris

          expect(ris).to include("TY  - #{ris_resource_type_identifier}")
          expect(ris).to include("T1  - #{title}")
          expect(ris).to include("T2  - #{alt_title1}")
          expect(ris).to include("AU  - #{creator1_last_name}, #{creator1_first_name}")
          expect(ris).to include("ED  - #{editor}")
          expect(ris).to include("DO  - https://doi.org/#{doi}")
          expect(ris).to include("AB  - #{abstract}")
          expect(ris).to include("KW  - #{keyword}")
          expect(ris).to include("PY  - #{published_year}")
          expect(ris).to include("PB  - #{publisher}")
          expect(ris).to include("PP  - #{place_of_publication}")
          expect(ris).to include("SN  - #{isbn}")
          expect(ris).to include("JO  - #{journal_title}")
          expect(ris).to include("LA  - #{language}")
          expect(ris).to include("N1  - #{add_info}")
          expect(ris).to include("IS  - #{issue}")
          expect(ris).to include("UR  - #{official_link}")
          expect(ris).to include("VL  - #{volume}")
          expect(ris).to include("ER  - ")
        end
      end

      describe "a complete work" do
        let(:attributes) do
          {
            "abstract" => abstract,
            "add_info" => add_info,
            "alt_title" => [alt_title1, alt_title2, ""],
            "book_title" => book_title,
            "contributor" => [contributor],
            "creator" => [[creator1, creator2].to_json],
            "date_accepted" => date_accepted,
            "date_published" => date_published,
            "date_submitted" => date_submitted,
            "doi": [doi],
            "duration" => [duration1, duration2, ""],
            "edition" => edition,
            "editor" => [editor],
            "eissn" => eissn,
            "institution" => [institution1, institution2],
            "isbn" => isbn,
            "issn" => issn,
            "issue" => issue,
            "journal_title" => journal_title,
            "keyword" => [keyword, keyword2, ""],
            "language" => [language, language2],
            "official_link" => official_link,
            "org_unit" => [org_unit1, org_unit2],
            "pagination" => pagination,
            "place_of_publication" => [place_of_publication, place_of_publication2],
            "project_name" => [project_name1, project_name2],
            "publisher" => [publisher, ""],
            "resource_type" => ["Other", ""],
            "series_name" => [series_name, ""],
            "source" => [""],
            "title" => [title],
            "version_number" => [version_number, ""],
            "volume" => [volume, ""]
          }
        end

        context "outputs correctly" do
          let(:ris) { metadata.ris }

          it { expect(ris).to include("TY  - GEN") }
          it { expect(ris).to include("T1  - #{title}") }
          it { expect(ris).to include("T2  - #{alt_title1}") }
          it { expect(ris).to include("T2  - #{alt_title2}") }
          it { expect(ris).to include("T2  - #{book_title}") }
          it { expect(ris).to include("AU  - #{creator1_last_name}, #{creator1_first_name}") }
          it { expect(ris).to include("AU  - #{creator2_last_name}, #{creator2_first_name}") }
          it { expect(ris).to include("ED  - #{editor}") }
          it { expect(ris).to include("AB  - #{abstract}") }
          it { expect(ris).to include("DA  - #{date_published}") }
          it { expect(ris).to include("DO  - https://doi.org/#{doi}") }
          it { expect(ris).to include("JO  - #{journal_title}") }
          it { expect(ris).to include("LA  - #{language}") }
          it { expect(ris).to include("LA  - #{language2}") }
          it { expect(ris).to include("N1  - #{add_info}") }
          it { expect(ris).to include("KW  - #{keyword}") }
          it { expect(ris).to include("KW  - #{keyword2}") }
          it { expect(ris).to include("IS  - #{issue}") }
          it { expect(ris).to include("PB  - #{publisher}") }
          it { expect(ris).to include("PP  - #{place_of_publication}") }
          it { expect(ris).to include("PP  - #{place_of_publication2}") }
          it { expect(ris).to include("PY  - #{published_year}") }
          it { expect(ris).to include("SN  - #{isbn}") }
          it { expect(ris).to include("SP  - #{pagination}") }
          it { expect(ris).to include("UR  - #{official_link}") }
          it { expect(ris).to include("VL  - #{volume}") }
          it { expect(ris).to include("ER  - ") }

          # Ensure the priority of the identifiers is being respected
          it { expect(ris).not_to include(issn) }
          it { expect(ris).not_to include(eissn) }
        end
      end
    end

    context "datacite" do
      subject(:datacite_xml) { Nokogiri::XML(datacite_string, &:strict).remove_namespaces! }
      let(:datacite_string) { metadata.datacite }

      it "creates datacite XML" do
        expect(datacite_string).to be_a String
        expect(datacite_xml).to be_a Nokogiri::XML::Document
      end

      it "sets the DOI" do
        url = "https://doi.org/#{doi}"
        expect(datacite_xml.xpath("/resource/identifier[@identifierType='DOI']/text()").to_s).to eq url
      end

      context "it correctly populates the datacite XML" do
        it { expect(datacite_xml.xpath("/resource/titles/title[1]/text()").to_s).to eq title }
        it { expect(datacite_xml.xpath("/resource/creators/creator[1]/creatorName/text()").to_s).to eq "#{creator1_last_name}, #{creator1_first_name}" }
        it { expect(datacite_xml.xpath("/resource/publisher/text()").to_s).to eq publisher }
        it { expect(datacite_xml.xpath("/resource/descriptions/description[1]/text()").to_s).to eq abstract }
        it { expect(datacite_xml.xpath("/resource/contributors/contributor[1]/contributorName/text()").to_s).to eq contributor }
        it { expect(datacite_xml.xpath("/resource/subjects/subject[1]/text()").to_s).to eq keyword }
        it { expect(JSON.parse(datacite_xml.xpath("/resource/language/text()").to_s).first).to eq language }
        it {
          xpath = "/resource/relatedIdentifiers/relatedIdentifier[@relatedIdentifierType='ISBN']/text()"
          expect(datacite_xml.xpath(xpath).to_s).to eq isbn
        }
      end

      it "sets the resource type" do
        type = JSON.parse(datacite_xml.xpath("/resource/resourceType[@resourceTypeGeneral='Other']/text()").to_s).first
        expect(type).to eq resource_type
      end

      context "publication year" do
        let(:create_date) { "1945-01-01" }
        let(:upload_date) { DateTime.parse("2009-12-25 11:30").iso8601 }

        it "sets year from date_published by default" do
          expect(datacite_xml.xpath("/resource/publicationYear/text()").to_s).to eq published_year
        end

        context "with date_created" do
          before do
            work.date_created = [create_date]
            work.date_uploaded = upload_date
            work.date_published = nil
          end

          it "sets year from date_created" do
            expect(datacite_xml.xpath("/resource/publicationYear/text()").to_s).to eq created_year
          end

          context "with only year" do
            let(:create_date) { "1945" }

            it "sets year from date_created" do
              expect(datacite_xml.xpath("/resource/publicationYear/text()").to_s).to eq created_year
            end
          end
        end

        context "with date_uploaded" do
          before do
            work.date_created = []
            work.date_uploaded = upload_date
            work.date_published = nil
          end

          it "sets year from date_uploaded" do
            expect(datacite_xml.xpath("/resource/publicationYear/text()").to_s).to eq "2009"
          end
        end

        context "without either" do
          before do
            work.date_created = []
            work.date_uploaded = nil
            work.date_published = nil
          end

          it "defaults to current year" do
            expect(datacite_xml.xpath("/resource/publicationYear/text()").to_s).to eq Date.today.year.to_s
          end
        end
      end
    end
  end
end
