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

  let(:attributes) do
    {
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

  # NOTE: If updating the schema files, you'll need to manually update the remove `schemaLocation` references
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

  # types = ['artistic-performance', 'book-chapter', 'book-review', 'book', 'conference-abstract', 'conference-paper', 'conference-poster', 'data-set', 'dictionary-entry', 'disclosure', 'dissertation', 'edited-book', 'encyclopedia-entry', 'invention', 'journal-article', 'journal-issue', 'lecture-speech', 'license', 'magazine-article', 'manual', 'newsletter-article', 'newspaper-article', 'online-resource', 'other', 'patent', 'registered-copyright', 'report', 'research-technique', 'research-tool', 'spin-off-company', 'standards-and-policy', 'supervised-student-publication', 'technical-standard', 'test', 'translation', 'trademark', 'website', 'working-paper']
  describe "#orcid_xml" do
    it "returns a nonempty XML document" do
      Dir.chdir(xml_path) do
        schema = Nokogiri::XML::Schema(IO.read(schema_file))

        # Ensure we aren't getting false positive resultss above
        doc = Nokogiri::XML(reader.orcid_xml("other"))
        # byebug
        expect(schema.validate(doc)).to be_empty
      end
    end
  end
end
