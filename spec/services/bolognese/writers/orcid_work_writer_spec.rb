# frozen_string_literal: true

require "rails_helper"

RSpec.describe Bolognese::Writers::OrcidXmlWriter do
  let(:abstract) { 'Swedish comic about the adventures of the residents of Moominvalley.' }
  let(:add_info) { "Nothing to report" }
  let(:alt_title1) { 'alt-title' }
  let(:alt_title2) { 'alt-title-2' }
  let(:book_title) { "Book Title 1" }
  let(:contributor) { 'Elizabeth Portch' }
  let(:created_year) { "1945" }
  let(:creator1) { 'Tove Jansson' }
  let(:creator2) { 'Creator 2' }
  let(:date_accepted) { "2018-01-02" }
  let(:date_created) { "#{created_year}-01-01" }
  let(:date_published) { "#{published_year}-01-01" }
  let(:date_submitted) { "2019-01-02" }
  let(:doi) { '10.18130/v3-k4an-w022' }
  let(:duration1) { "duration1" }
  let(:duration2) { "duration2" }
  let(:edition) { "1" }
  let(:editor) { "Test Editor" }
  let(:eissn) { "1234-5678" }
  let(:institution1) { "British Library" }
  let(:institution2) { "British Museum" }
  let(:isbn) { "9781770460621" }
  let(:issn) { "0987654321" }
  let(:issue) { 7 }
  let(:journal_title) { "Test Journal Title" }
  let(:keyword) { 'Lighthouses' }
  let(:keyword2) { 'Hippos' }
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
  let(:publisher) { 'Schildts' }
  let(:resource_type) { "Book" }
  let(:ris_resource_type_identifier) { "BOOK" }
  let(:series_name) { "Series name" }
  let(:title) { 'Moomin' }
  let(:version_number) { "3" }
  let(:volume) { 2 }

  let(:attributes) do {
      "abstract" => abstract,
      "add_info" => add_info,
      "alt_title" => [alt_title1, alt_title2, ""],
      "book_title" => book_title,
      "contributor" => [contributor],
      "creator": [creator1, creator2, ""],
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
      "place_of_publication" => [place_of_publication1, place_of_publication2],
      "project_name" => [project_name1, project_name2],
      "publisher" => [publisher, ""],
      "resource_type": ["Other", ""],
      "series_name" => [series_name, ""],
      "source" => [""],
      "title": [title],
      "version_number" => [version_number, ""],
      "volume" => [volume, ""]
    }
  end

  let(:model_class) { GenericWork }
  let(:work) { model_class.new(attributes) }
  let(:input) { work.attributes.merge(has_model: work.has_model.first).to_json }
  let(:reader) { Bolognese::Readers::GenericWorkReader.new(input: input, from: "work") }
  let(:result) { reader.orcid_xml }

  it "includes the module into the Metadata class" do
    expect(Bolognese::Metadata.new).to respond_to(:orcid_xml)
  end

  it { result }

  describe "the schema" do
    # NOTE: If updating the schema files, you'll need to manuall update the remove `schemaLocation` references
    let(:schema_path) { Rails.root.join("..", "fixtures", "orcid", "xml", "record_2.1", "work-2.1.xsd") }
    let(:schema_validator) { Nokogiri::XML::Schema(schema_path.open) }
    let(:sample_xml_path) { Rails.root.join("..", "fixtures", "orcid", "xml", "record_2.1", "example-simple-2.1.xml") }

    it "returns an XML document that matches the schema" do
      # Validate a sample file to enure we can trust the schema - a valid result returns an empty array
      sample = Nokogiri::XML(sample_xml_path.open)
      expect(schema_validator.validate(sample)).to be_empty

      # Validate our XML result
      xml_result = Nokogiri::XML(result)
      expect(schema_validator.validate(xml_result)).to be_empty
    end
  end

  describe "#orcid_xml" do
    it "returns a nonempty XML document" do
      doc = Nokogiri::XML::Document.parse(result)
      nodes = doc.xpath
      expect(nodes.empty?).to be false
    end
  end
end
