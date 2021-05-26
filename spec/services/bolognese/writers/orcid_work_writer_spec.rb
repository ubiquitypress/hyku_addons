# frozen_string_literal: true

require "rails_helper"

RSpec.describe Bolognese::Writers::OrcidXmlWriter do
  let(:abstract) { "Swedish comic about the adventures of the residents of Moominvalley." }
  let(:add_info) { "Nothing to report" }
  let(:alt_title1) { "alt-title" }
  let(:contributor) { "Elizabeth Portch" }
  let(:created_year) { "1945" }
  let(:creator1_first_name) { "Sebastian" }
  let(:creator1_last_name) { "Hageneuer" }
  let(:creator2_first_name) { "Johnny" }
  let(:creator2_last_name) { "Testing" }
  let(:creator1) do
    {
      "nameType" => "Personal",
      "name" => "#{creator1_last_name}, #{creator1_first_name}",
      "givenName" => creator1_first_name,
      "familyName" => creator1_last_name
    }
  end
  let(:creator2) do
    {
      "name" => "#{creator2_last_name}, #{creator2_first_name}",
      "givenName" => creator2_first_name,
      "familyName" => creator2_last_name,
      "nameIdentifiers" => [
        { "nameIdentifier" => "12345678890", "nameIdentifierScheme" => "orcid" }
      ]
    }
  end
  let(:date_created) { "#{created_year}-01-01" }
  let(:date_published) { "#{published_year}-01-01" }
  let(:doi) { "10.18130/v3-k4an-w022" }
  let(:editor) { "Test Editor" }
  let(:isbn) { "9781770460621" }
  let(:issn) { "0987654321" }
  let(:keyword) { "Lighthouses" }
  let(:language) { "Swedish" }
  let(:official_link) { "http://test-url.com" }
  let(:place_of_publication) { "Finland" }
  let(:published_year) { "1946" }
  let(:publisher) { "Schildts" }
  let(:resource_type) { "Book" }
  let(:title) { "Moomin" }
  let(:volume) { 2 }
  let(:issue) { "2" }

  let(:attributes) do
    {
      doi: [doi],
      title: [title],
      alt_title: [alt_title1],
      resource_type: [resource_type],
      creator: [[creator1, creator2].to_json],
      contributor: [contributor],
      publisher: [publisher],
      abstract: abstract,
      keyword: [keyword],
      date_created: [date_created],
      date_published: date_published,
      editor: [editor],
      isbn: isbn,
      place_of_publication: [place_of_publication],
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
  let(:meta) { Bolognese::Readers::GenericWorkReader.new(input: input, from: "work") }

  # NOTE: If updating the schema files, you"ll need to manually update the remove `schemaLocation` references
  let(:xml_path) { Rails.root.join("..", "fixtures", "orcid", "xml", "record_2.1") }

  let(:schema_file) { "work-2.1.xsd" }
  let(:simple_sample_path) { Rails.root.join("..", "fixtures", "orcid", "xml", "record_2.1", "example-simple-2.1.xml") }
  let(:complete_sample_path) { Rails.root.join("..", "fixtures", "orcid", "xml", "record_2.1", "example-simple-2.1.xml") }
  let(:error_sample_path) { Rails.root.join("..", "fixtures", "orcid", "xml", "record_2.1", "example-error.xml") }

  it "includes the module into the Metadata class" do
    expect(Bolognese::Metadata.new).to respond_to(:orcid_xml)
  end

  describe "the schema" do
    it "validates against the test XML documents" do
      # Because of the way the documents need to be altered to use relative schemaLocation's, Dir.chdir is required
      Dir.chdir(xml_path) do
        schema = Nokogiri::XML::Schema(IO.read(schema_file))

        doc = Nokogiri::XML(IO.read(simple_sample_path))
        expect(schema.validate(doc)).to be_empty

        doc = Nokogiri::XML(IO.read(complete_sample_path))
        expect(schema.validate(doc)).to be_empty

        # Ensure we aren't getting false positive resultss above
        doc = Nokogiri::XML(IO.read(error_sample_path))
        expect(schema.validate(doc)).not_to be_empty
      end
    end
  end

  describe "#orcid_xml" do
    subject(:orcid_xml) { meta.orcid_xml("other") }
    let(:doc) { Nokogiri::XML(orcid_xml) }

    # This is just for debugging to show what is being output
    it "outputs the XML" do
      puts "==================================================================="
      puts orcid_xml
      puts "==================================================================="
    end

    it "returns a valid XML document" do
      Dir.chdir(xml_path) do
        schema = Nokogiri::XML::Schema(IO.read(schema_file))

        doc = Nokogiri::XML(orcid_xml)
        expect(schema.validate(doc)).to be_empty
      end
    end

    it { byebug }
    it { expect(datacite_xml.xpath("/resource/identifier[@identifierType='DOI']/text()").to_s).to eq url }

  end
end
