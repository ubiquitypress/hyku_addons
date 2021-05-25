# frozen_string_literal: true

require "rails_helper"

RSpec.describe Bolognese::Writers::OrcidXmlWriter do
  let(:abstract) { 'Swedish comic about the adventures of the residents of Moominvalley.' }
  let(:add_info) { "Nothing to report" }
  let(:alt_title1) { 'alt-title' }
  let(:alt_title2) { 'alt-title-2' }
  let(:book_title) { "Book Title 1" }
  let(:contributor) do
    {
      "contributor_organization_name" => "",
      "contributor_given_name" => "Johnny",
      "contributor_family_name" => "Smithy",
      "contributor_name_type" => "Personal",
      "contributor_orcid" => "",
      "contributor_isni" => "",
      "contributor_ror" => "",
      "contributor_grid" => "",
      "contributor_wikidata" => "",
      "contributor_type" => "Other"
    }
  end
  let(:creator) do
    {
      "creator_organization_name" => "",
      "creator_given_name" => "Sebastian",
      "creator_family_name" => "Hageneuer",
      "creator_name_type" => "Personal",
      "creator_orcid" => "https://orcid.org/0000-0001-8973-1544",
      "creator_isni" => "",
      "creator_ror" => "",
      "creator_grid" => "",
      "creator_wikidata" => ""
    }
  end
  let(:date_accepted) { "1992-5-6" }
  let(:date_published) { "2020-2-6" }
  let(:published_year) { "2020" }
  let(:date_submitted) { "1980-4-8" }
  let(:doi) { '10.18130/v3-k4an-w022' }
  let(:edition) { "1" }
  let(:editor) { "Test Editor" }
  let(:eissn) { "1234-5678" }
  let(:institution1) { "British Library" }
  let(:institution2) { "British Museum" }
  let(:isbn) { "9781770460621" }
  let(:issn) { "0987654321" }
  let(:issue) { 7 }
  let(:keywords) { ['Lighthouses', 'Hippos'] }
  let(:language) { "Swedish" }
  let(:official_link) { "http://test-url.com" }
  let(:pagination) { "1-2" }
  let(:publisher) { 'Schildts' }
  let(:resource_type) { "Book" }
  let(:series_name) { "Series nme" }
  let(:title) { 'Moomin' }
  let(:version_number) { "3" }
  let(:volume) { 2 }

  let(:attributes) do
    {
      # "depositor" => "paul.danelli+admin@ubiquitypress.com",
      "title" => ["Communicating the Past in the Digital Age: Proceedings of the International Conference on Digital Methods in Teaching and Learning in Archaeology (12th-13th October 2018)"],
      # "official_link" => "https://www.ubiquitypress.com/site/books/10.5334/bch/",
      # "institution" => ["British Library"],
      # "date_published" => "2020-2-6",
      # "date_accepted" => "1992-5-6",
      # "date_submitted" => "1980-4-8",
      # "doi" => ["10.5334/bch"],
      # "volume" => ["2"],
      # "book_title" => "Communicating the Past in the Digital Age: Proceedings of the International Conference on Digital Methods in Teaching and Learning in Archaeology (12th-13th October 2018)",
      # "isbn" => "9781911529842",
      # "resource_type" => ["Cartographic material"],
      "creator" => [
        [
          {
            "creator_organization_name"=>"",
            "creator_given_name"=>"Sebastian",
            "creator_family_name"=>"Hageneuer",
            "creator_name_type"=>"Personal",
            "creator_orcid"=>"https://orcid.org/0000-0001-8973-1544",
            "creator_isni"=>"",
            "creator_ror"=>"",
            "creator_grid"=>"",
            "creator_wikidata"=>""
          }
        ].to_json
      ]
    }
  end

  context "" do
    it {
      work =  GenericWork.new(attributes)
      input = work.attributes.merge(has_model: work.has_model.first).to_json
      meta = Bolognese::Readers::GenericWorkReader.new(input: input, from: "work")

      meta.send(:read_creator)
    }

  end

  let(:model_class) { GenericWork }
  let(:work) { model_class.new(attributes) }
  let(:input) { work.attributes.merge(has_model: work.has_model.first).to_json }
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

  describe "#orcid_xml" do
    it "outputs the XML" do
      puts '==================================================================='
      puts meta meta.orcid_xml("other")
      puts '==================================================================='
    end

    it "returns a nonempty XML document" do
      Dir.chdir(xml_path) do
        schema = Nokogiri::XML::Schema(IO.read(schema_file))

        doc = Nokogiri::XML(meta.orcid_xml("other"))
        expect(schema.validate(doc)).to be_empty
      end
    end
  end
end
