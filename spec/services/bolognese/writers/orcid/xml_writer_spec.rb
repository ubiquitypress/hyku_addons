# frozen_string_literal: true

require "rails_helper"

RSpec.describe Bolognese::Writers::Orcid::XmlWriter do
  let(:description) { "Swedish comic about the adventures of the residents of Moominvalley." }
  let(:creator1_first_name) { "Sebastian" }
  let(:creator1_last_name) { "Hageneuer" }
  let(:creator1) do
    {
      "creator_given_name" => creator1_first_name,
      "creator_family_name" => creator1_last_name,
    }
  end
  let(:creator2_first_name) { "Johnny" }
  let(:creator2_last_name) { "Testing" }
  let(:creator2_orcid) { "0000-0001-5109-3701" }
  let(:creator2) do
    {
      "creator_given_name" => creator2_first_name,
      "creator_family_name" => creator2_last_name,
      "creator_orcid" => "https://orcid.org/#{creator2_orcid}"
    }
  end
  let(:contributor1_first_name) { "Jannet" }
  let(:contributor1_last_name) { "Gnitset" }
  let(:contributor1_orcid) { "0000-1234-5109-3702" }
  let(:contributor1_role) { "Other" }
  let(:contributor1) do
    {
      "contributor_given_name" => contributor1_first_name,
      "contributor_family_name" => contributor1_last_name,
      "contributor_orcid" => "https://orcid.org/#{contributor1_orcid}",
    }
  end
  let(:date_created) { "#{created_year}-08-19" }
  let(:doi) { "10.18130/v3-k4an-w022" }
  let(:isbn) { "9781770460621" }
  let(:issn) { "0987654321" }
  let(:keyword) { "Lighthouses" }
  let(:language) { "Swedish" }
  let(:created_year) { "1983" }
  let(:publisher) { "Schildts" }
  let(:resource_type) { "Book" }
  let(:title) { "Moomin" }

  let(:attributes) do
    {
      title: [title],
      resource_type: [resource_type],
      creator: [[creator1, creator2].to_json],
      contributor: [[contributor1].to_json],
      publisher: [publisher],
      description: [description],
      keyword: [keyword],
      date_created: [date_created],
      identifier: [isbn, doi],
      language: [language]
    }
  end

  let(:xml_path) { Rails.root.join("..", "fixtures", "orcid", "xml", "record_2.1") }
  let(:schema_file) { "work-2.1.xsd" }

  let(:model_class) { GenericWork }
  let(:work) { model_class.new(attributes) }
  let(:input) { work.attributes.merge(has_model: work.has_model.first).to_json }
  let(:meta) { Bolognese::Metadata.new(input: input, from: "hyku_addons_work") }
  let(:type) { "other" }
  let(:put_code) { nil }
  let(:hyrax_orcid_xml) { meta.hyrax_orcid_xml(type, put_code) }
  let(:doc) { Nokogiri::XML(hyrax_orcid_xml) }

  it "includes the module into the Metadata class" do
    expect(Bolognese::Metadata.new).to respond_to(:hyrax_orcid_xml)
    expect(Bolognese::Metadata.ancestors).to include(Bolognese::Writers::HykuAddonsWorkFormFieldsWriter)
  end

  describe "#hyrax_orcid_xml" do
    context "when `put_code` is provided" do
      let(:put_code) { "987654321" }

      xit "includes the put-code in the root attributes" do
        expect(doc.root.attributes.dig("put-code").to_s).to eq put_code
      end
    end

    context "when type is `other`" do
      before do
        work.save
      end

      it "returns a valid XML document" do
        Dir.chdir(xml_path) do
          schema = Nokogiri::XML::Schema(IO.read(schema_file))

          doc = Nokogiri::XML(hyrax_orcid_xml)
          expect(schema.validate(doc)).to be_empty
        end
      end

      describe "attributes" do
        xit "doesn't includes the put-code in the root attributes" do
          expect(doc.root.attributes.keys).not_to include("put-code")
          expect(doc.root.attributes.dig("put-code")).to be_nil
        end
      end

      describe "titles" do
        it { expect(doc.xpath("//common:title/text()").to_s).to eq title }
      end

      describe "creators" do
        xit { expect(doc.xpath("//work:contributor").count).to eq 3 }

        xit { expect(doc.xpath("//work:contributor[1]/common:contributor-orcid/common:path/text()").to_s).to eq "" }
        xit { expect(doc.xpath("//work:contributor[1]/work:credit-name/text()").to_s).to eq "#{creator1_first_name} #{creator1_last_name}" }
        xit { expect(doc.xpath("//work:contributor[1]/work:contributor-attributes/work:contributor-role/text()").to_s).to eq "author" }
        xit { expect(doc.xpath("//work:contributor[1]/work:contributor-attributes/work:contributor-sequence/text()").to_s).to eq "first" }

        xit { expect(doc.xpath("//work:contributor[2]/common:contributor-orcid/common:path/text()").to_s).to eq creator2_orcid }
        xit { expect(doc.xpath("//work:contributor[2]/work:credit-name/text()").to_s).to eq "#{creator2_first_name} #{creator2_last_name}" }
        xit { expect(doc.xpath("//work:contributor[2]/work:contributor-attributes/work:contributor-role/text()").to_s).to eq "author" }
        xit { expect(doc.xpath("//work:contributor[2]/work:contributor-attributes/work:contributor-sequence/text()").to_s).to eq "additional" }

        xit { expect(doc.xpath("//work:contributor[3]/common:contributor-orcid/common:path/text()").to_s).to eq contributor1_orcid }
        xit { expect(doc.xpath("//work:contributor[3]/work:credit-name/text()").to_s).to eq "#{contributor1_first_name} #{contributor1_last_name}" }
        xit { expect(doc.xpath("//work:contributor[3]/work:contributor-attributes/work:contributor-role/text()").to_s).to eq "support-staff" }
        xit { expect(doc.xpath("//work:contributor[3]/work:contributor-attributes/work:contributor-sequence/text()").to_s).to eq "additional" }
      end
    end
  end
end


