# frozen_string_literal: true
require "rails_helper"

RSpec.describe Bolognese::Readers::GenericWorkReader do
  let(:doi) { '10.18130/v3-k4an-w022' }
  let(:title) { 'Moomin' }
  # let(:alt_title) { 'alt-title' }
  let(:resource_type) { "Book" }
  let(:creator) { 'Tove Jansson' }
  let(:contributor) { 'Elizabeth Portch' }
  let(:publisher) { 'Schildts' }
  let(:abstract) { 'Swedish comic about the adventures of the residents of Moominvalley.' }
  let(:keyword) { 'Lighthouses' }
  let(:date_created) { 1945 }
  let(:published_year) { 1946 }
  let(:date_published) { "#{published_year}-01-01" }
  let(:editor) { "Test Editor" }
  let(:isbn) { "9781770460621" }
  let(:place_of_publication) { "Finland" }
  let(:journal_title) { "Test Journal Title" }
  let(:language) { "Swedish" }
  let(:add_info) { "Nothing to report" }
  let(:issue) { 7 }
  let(:official_link) { "http://test-url.com" }
  let(:volume) { 2 }
  let(:attributes) do
    {
      doi: [doi],
      # FIXME: If more than one title is provided, the order is nondeterministic.
      title: [title],
      resource_type: [resource_type],
      creator: [creator],
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
  let(:ris_resource_type_identifier) { "BOOK" }

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
          # FIXME: If more than one title is provided, the order is nondeterministic.
          # expect(ris).to include("T2  - #{alt_title}")
          expect(ris).to include("AU  - #{creator}")
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
            "title": ["A work with all fields completed.", ""],
            "resource_type": ["Other", ""],
            "editor" => [
              {
                "editor_name_type" => "Personal",
                "editor_family_name" => "Chickpea",
                "editor_given_name" => "Charlie",
                "editor_orcid" => "0000-0003-2763-9755",
              }.to_json
            ],
            "creator": [
              {
                "creator_name_type" => "Personal",
                "creator_family_name" => "Chorizo",
                "creator_given_name" => "Cherry-Ann",
                "creator_orcid" => "0000-0003-2763-9755",
                "creator_institutional_relationship" => ["Staff member"],
                "creator_isni" => "123123123"
              }.to_json,
              {
                "creator_name_type" => "Personal",
                "creator_family_name" => "Gould",
                "creator_given_name" => "Sara",
                "creator_institutional_relationship" => ["Staff member"],
              }.to_json
            ],
            "contributor": [
              {
                "contributor_name_type" => "Personal",
                "contributor_organization_name" => "",
                "contributor_family_name" => "Cheddar",
                "contributor_given_name" => "Cheese",
                "contributor_orcid" => "0000-0003-2763-9755",
                "contributor_isni" => "0000000459890159",
                "contributor_type" => "Project Leader"
              }.to_json,
              {
                "contributor_name_type" => "Organisational",
                "contributor_organization_name" => "The Cornflake House",
                "contributor_type" => "Hosting Institution"
              }.to_json
            ],
            "institution": ["British Library", "British Museum", ""],
            "alt_title": ["Alternative title1", "Alternative title2", ""],
            "date_published" => {
              "date_published_year" => "2017",
              "date_published_month" => "6",
              "date_published_day" => "8"
            }.to_json,
            "abstract" => "So many foods starting with c. Including chapati and clementines.",
            "media" => ["Image", "Food", ""],
            "duration" => ["duration1", "duration2", ""],
            "org_unit" => ["Department of Crackers", "Department2", ""],
            "project_name" => ["Project name2", "The Chicken project", ""],
            "funder" => [
              {
                "funder_name" => "Henry Moore Foundation",
                "funder_doi" => "http://dx.doi.org/10.13039/100012062",
              }.to_json
            ],
            "fndr_project_ref" => ["Project reference1", "Project reference2", ""],
            "event_title" => ["Cheese & Chocolate conference", "Event title2", ""],
            "event_location" => ["Scarborough", "Event location2", ""],
            "event_date" => [
              {
                "event_date_year" => "",
                "event_date_month" => "",
                "event_date_day" => ""
              }.to_json
            ],
            "series_name" => ["Series name2", ""],
            "book_title" => "Book title",
            "journal_title" => "Celery and Celeriac Times",
            "alternative_journal_title" => ["Alternative journal title2", "Alternative journal title1", ""],
            "volume" => ["6", ""],
            "edition" => "1",
            "version_number" => ["2", ""],
            "issue" => "3",
            "pagination" => "1-2",
            "article_num" => "e123",
            "publisher" => ["Crisps and Chips Publisher", ""],
            "place_of_publication" => ["Buenos Aires, Argentina", "Place of publication2", ""],
            "isbn" => "1234567890",
            "issn" => "0987654321",
            "eissn" => "1234-5678",
            "date_accepted" => {
              "date_accepted_year" => "2018",
              "date_accepted_month" => "1",
              "date_accepted_day" => "2"
            }.to_json,
            "date_submitted" => {
              "date_submitted_year" => "2019",
              "date_submitted_month" => "1",
              "date_submitted_day" => "2"
            }.to_json,
            "official_link" => "https://bl.oar.bl.uk/concern/book_contributions/3b41adc3-dfd0-4be3-a682-b78b6c5ed86d?locale=en",
            "related_url" => ["https://ubiquitypress.com", "https://bl.uk", ""],
            "related_exhibition" => ["Related exhibition1", "Related exhibition2", ""],
            "related_exhibition_venue" => ["Related exhibition venue2", "Related exhibition venue1", ""],
            "related_exhibition_date" => [""],
            "language" => ["Fra", "Eng", ""],
            "license" => [
              "http://creativecommons.org/publicdomain/zero/1.0/",
              "http://creativecommons.org/licenses/by/3.0/us/",
              ""
            ],
            "rights_statement" => ["http://rightsstatements.org/vocab/InC/1.0/"],
            "rights_holder" => ["Rights holder2", "Custard Inc", ""],
            "qualification_name" => "PhD",
            "qualification_level" => "Doctoral",
            "alternate_identifier" => [
              {
                "alternate_identifier" => "ABC 123456",
                "alternate_identifier_type" => "Cheese type"
              }.to_json,
              {
                "alternate_identifier" => "DEF 8910",
                "alternate_identifier_type" => "Type of alternate identifier2"
              }.to_json
            ],
            "related_identifier" => [
              {
                "related_identifier" => "9780297609445",
                "related_identifier_type" => "ISBN",
                "relation_type" => "IsSupplementedBy"
              }.to_json
            ],
            "refereed" => "Peer-reviewed",
            "keyword" => ["Food", "Banana", ""],
            "dewey" => "123",
            "library_of_congress_classification" => ["AB", "CD", ""],
            "add_info" => "This record contains data in almost every field. Search foods beginning with c. Except rhubarb... additional fields filled with non-food-based items by Tom.",
            "source" => [""],
          }
        end

        it "outputs correctly" do
          ris = metadata.ris
byebug
          expect(ris).to include("TY  - GEN")
          expect(ris).to include("T1  - A work with all fields completed.")
          expect(ris).to include("T2  - Book title")
          expect(ris).to include("T2  - Alternative title1")
          expect(ris).to include("T2  - Alternative title2")
          expect(ris).to include("AU  - Chorizo, Cherry-Ann")
          expect(ris).to include("AU  - Gould, Sara")
          expect(ris).to include("ED  - Chickpea, Charlie")
          expect(ris).to include("AB  - So many foods starting with c. Including chapati and clementines.")
          expect(ris).to include("DA  - 2017-6-8")
          # expect(ris).to include("DO  - doi.org/10.21250/tcq")
          expect(ris).to include("JO  - Celery and Celeriac Times")
          expect(ris).to include("LA  - Eng")
          expect(ris).to include("N1  - This record contains data in almost every field. Search foods beginning with c. Except rhubarb... additional fields filled with non-food-based items by Tom.")
          expect(ris).to include("KW  - Banana")
          expect(ris).to include("KW  - Food")
          expect(ris).to include("IS  - 3")
          expect(ris).to include("PB  - Crisps and Chips Publisher")
          expect(ris).to include("PP  - Place of publication2")
          expect(ris).to include("PY  - 2017")
          expect(ris).to include("SN  - 1234567890")
          expect(ris).to include("SP  - 1-2")
          expect(ris).to include("UR  - https://bl.oar.bl.uk/concern/book_contributions/3b41adc3-dfd0-4be3-a682-b78b6c5ed86d?locale=en")
          expect(ris).to include("VL  - 6")
          expect(ris).to include("ER  - ")
        end
      end
    end

    context 'datacite' do
      subject(:datacite_xml) { Nokogiri::XML(datacite_string, &:strict).remove_namespaces! }
      let(:datacite_string) { metadata.datacite }

      it 'creates datacite XML' do
        expect(datacite_string).to be_a String
        expect(datacite_xml).to be_a Nokogiri::XML::Document
      end

      it 'sets the DOI' do
        url = "https://doi.org/#{doi}"
        expect(datacite_xml.xpath('/resource/identifier[@identifierType="DOI"]/text()').to_s).to eq url
      end

      context 'it correctly populates the datacite XML' do
        it { expect(datacite_xml.xpath('/resource/titles/title[1]/text()').to_s).to eq title }
        it { expect(datacite_xml.xpath('/resource/creators/creator[1]/creatorName/text()').to_s).to eq creator }
        it { expect(datacite_xml.xpath('/resource/publisher/text()').to_s).to eq publisher }
        it { expect(datacite_xml.xpath('/resource/descriptions/description[1]/text()').to_s).to eq abstract }
        it { expect(datacite_xml.xpath('/resource/contributors/contributor[1]/contributorName/text()').to_s).to eq contributor }
        it { expect(datacite_xml.xpath('/resource/subjects/subject[1]/text()').to_s).to eq keyword }
        it { expect(JSON.parse(datacite_xml.xpath('/resource/language/text()').to_s).first).to eq language }
        it {
          xpath = '/resource/relatedIdentifiers/relatedIdentifier[@relatedIdentifierType="ISBN"]/text()'
          expect(datacite_xml.xpath(xpath).to_s).to eq isbn
        }
      end

      it 'sets the resource type' do
        type = JSON.parse(datacite_xml.xpath('/resource/resourceType[@resourceTypeGeneral="Other"]/text()').to_s).first
        expect(type).to eq resource_type
      end

      context 'publication year' do
        let(:create_date) { '1945-01-01' }
        let(:upload_date) { DateTime.parse('2009-12-25 11:30').iso8601 }

        it 'sets year from date_published by default' do
          expect(datacite_xml.xpath('/resource/publicationYear/text()').to_s).to eq "1946"
        end

        context 'with date_created' do
          before do
            work.date_created = [create_date]
            work.date_uploaded = upload_date
            work.date_published = nil
          end

          it 'sets year from date_created' do
            expect(datacite_xml.xpath('/resource/publicationYear/text()').to_s).to eq "1945"
          end

          context 'with only year' do
            let(:create_date) { '1945' }

            it 'sets year from date_created' do
              expect(datacite_xml.xpath('/resource/publicationYear/text()').to_s).to eq "1945"
            end
          end
        end

        context 'with date_uploaded' do
          before do
            work.date_created = []
            work.date_uploaded = upload_date
            work.date_published = nil
          end

          it 'sets year from date_uploaded' do
            expect(datacite_xml.xpath('/resource/publicationYear/text()').to_s).to eq "2009"
          end
        end

        context 'without either' do
          before do
            work.date_created = []
            work.date_uploaded = nil
            work.date_published = nil
          end

          it 'defaults to current year' do
            expect(datacite_xml.xpath('/resource/publicationYear/text()').to_s).to eq Date.today.year.to_s
          end
        end
      end
    end
  end
end
