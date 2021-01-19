# frozen_string_literal: true
require "rails_helper"

RSpec.describe Bolognese::Readers::GenericWorkReader do
  let(:identifier) { '123456' }
  let(:doi) { '10.18130/v3-k4an-w022' }
  let(:title) { 'Moomin' }
  # let(:alt_title) { 'alt-title' }
  let(:creator) { 'Tove Jansson' }
  let(:contributor) { 'Elizabeth Portch' }
  let(:publisher) { 'Schildts' }
  let(:description) { 'Swedish comic about the adventures of the residents of Moominvalley.' }
  let(:keyword) { 'Lighthouses' }
  let(:date_created) { 1945 }
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
      identifier: [identifier],
      doi: [doi],
      # FIXME: If more than one title is provided, the order is nondeterministic.
      title: [title],
      creator: [creator],
      contributor: [contributor],
      publisher: [publisher],
      description: [description],
      keyword: [keyword],
      date_created: [date_created],
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
      it "correctly populates the export" do
        ris = metadata.ris

        expect(ris).to include("T1  - #{title}")
        # FIXME: If more than one title is provided, the order is nondeterministic.
        # expect(ris).to include("T2  - #{alt_title}")
        expect(ris).to include("AU  - #{creator}")
        expect(ris).to include("ED  - #{editor}")
        expect(ris).to include("DO  - https://doi.org/#{doi}")
        expect(ris).to include("AB  - #{description}")
        expect(ris).to include("KW  - #{keyword}")
        expect(ris).to include("PY  - #{date_created}")
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

    context 'datacite' do
      subject(:datacite_xml) { Nokogiri::XML(datacite_string, &:strict).remove_namespaces! }
      let(:datacite_string) { metadata.datacite }

      it 'creates datacite XML' do
        expect(datacite_string).to be_a String
        expect(datacite_xml).to be_a Nokogiri::XML::Document
      end

      it 'sets the DOI' do
        expect(datacite_xml.xpath('/resource/identifier[@identifierType="DOI"]/text()').to_s).to eq "https://doi.org/#{doi}"
      end

      it 'correctly populates the datacite XML' do
        expect(datacite_xml.xpath('/resource/titles/title[1]/text()').to_s).to eq title
        expect(datacite_xml.xpath('/resource/creators/creator[1]/creatorName/text()').to_s).to eq creator
        expect(datacite_xml.xpath('/resource/publisher/text()').to_s).to eq publisher
        expect(datacite_xml.xpath('/resource/descriptions/description[1]/text()').to_s).to eq description
        expect(datacite_xml.xpath('/resource/contributors/contributor[1]/contributorName/text()').to_s).to eq contributor
        expect(datacite_xml.xpath('/resource/subjects/subject[1]/text()').to_s).to eq keyword
        expect(datacite_xml.xpath('/resource/alternateIdentifiers/alternateIdentifier[1]/text()').to_s).to eq identifier
      end

      it 'sets the hyrax work type' do
        string = 'GenericWork'
        expect(datacite_xml.xpath('/resource/resourceType[@resourceTypeGeneral="Other"]/text()').to_s).to eq string
      end

      context 'publication year' do
        let(:create_date) { '1945-01-01' }
        let(:upload_date) { DateTime.parse('2009-12-25 11:30').iso8601 }

        context 'with date_created' do
          before do
            work.date_created = [create_date]
            work.date_uploaded = upload_date
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
          end

          it 'sets year from date_uploaded' do
            expect(datacite_xml.xpath('/resource/publicationYear/text()').to_s).to eq "2009"
          end
        end

        context 'without either' do
          before do
            work.date_created = []
            work.date_uploaded = nil
          end

          it 'defaults to current year' do
            expect(datacite_xml.xpath('/resource/publicationYear/text()').to_s).to eq Date.today.year.to_s
          end
        end
      end
    end
  end
end
