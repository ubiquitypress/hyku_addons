# frozen_string_literal: true

require "rails_helper"

# NOTE: We are not actualy testing the Orcid XML Writer, as that delegates the building of the XML to a Module
# that we override inside of HykuAddons - We are testing the output of that module.
RSpec.describe Bolognese::Writers::Orcid::XmlWriter do
  let(:abstract) { "Swedish comic about the adventures of the residents of Moominvalley." }
  let(:add_info) { "Nothing to report" }
  let(:alt_title1) { "alt-title" }
  let(:book_title) { "Book Title 1" }
  let(:created_year) { "1945" }
  let(:creator1_first_name) { "Sebastian" }
  let(:creator1_last_name) { "Hageneuer" }
  let(:creator1_orcid) { "0000-0003-0652-4625" }
  let(:creator1) do
    {
      creator_name_type: "Personal",
      creator_given_name: creator1_first_name,
      creator_family_name: creator1_last_name,
      creator_orcid: "https://sandbox.orcid.org/#{creator1_orcid}"
    }
  end
  let(:creator2_first_name) { "Johnny" }
  let(:creator2_last_name) { "Testing" }
  let(:creator2) do
    {
      creator_name_type: "Personal",
      creator_given_name: creator2_first_name,
      creator_family_name: creator2_last_name
    }
  end
  let(:contributor1_first_name) { "Jannet" }
  let(:contributor1_last_name) { "Gnitset" }
  let(:contributor1_orcid) { "0000-1234-5109-3702" }
  let(:contributor1_role) { "Other" }
  let(:contributor1) do
    {
      contributor_name_type: "Personal",
      contributor_given_name: contributor1_first_name,
      contributor_family_name: contributor1_last_name,
      contributor_orcid: "https://orcid.org/#{contributor1_orcid}"
    }
  end
  let(:date_accepted) { "2018-01-02" }
  let(:date_created) { "#{created_year}-01-01" }
  let(:date_published) { "#{published_year}-03-12" }
  let(:date_submitted) { "2019-01-02" }
  let(:doi) { "10.18130/v3-k4an-w022" }
  let(:duration1) { "duration1" }
  let(:duration2) { "duration2" }
  let(:edition) { "1" }
  let(:editor1_first_name) { "Joan" }
  let(:editor1_last_name) { "Smile" }
  let(:editor1_orcid) { "4567-1234-0987-1234" }
  let(:editor1_role) { "Other" }
  let(:editor1) do
    {
      editor_name_type: "Personal",
      editor_given_name: editor1_first_name,
      editor_family_name: editor1_last_name,
      editor_orcid: "https://orcid.org/#{editor1_orcid}"
    }
  end
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
  let(:place_of_publication1) { "Finland" }
  let(:place_of_publication2) { "Buenos Aires, Argentina" }
  let(:project_name1) { "Project name2" }
  let(:project_name2) { "The Chicken projectca" }
  let(:published_year) { "1946" }
  let(:publisher) { "Schildts" }
  let(:resource_type) { "Book" }
  let(:series_name) { "Series name" }
  let(:title) { "Moomin" }
  let(:version_number) { "3" }
  let(:volume) { 2 }

  let(:attributes) do
    {
      abstract: abstract,
      add_info: add_info,
      alt_title: [alt_title1, ""],
      book_title: book_title,
      contributor: [[contributor1].to_json],
      creator: [[creator1, creator2].to_json],
      date_accepted: date_accepted,
      date_published: date_published,
      date_submitted: date_submitted,
      doi: [doi],
      duration: [duration1, duration2, ""],
      edition: edition,
      editor: [[editor1].to_json],
      eissn: eissn,
      institution: [institution1, institution2],
      isbn: isbn,
      issn: issn,
      issue: issue,
      journal_title: journal_title,
      keyword: [keyword, keyword2, ""],
      language: [language, language2],
      official_link: official_link,
      org_unit: [org_unit1, org_unit2],
      pagination: pagination,
      place_of_publication: [place_of_publication1, place_of_publication2],
      project_name: [project_name1, project_name2],
      publisher: [publisher, ""],
      resource_type: [resource_type, ""],
      series_name: [series_name, ""],
      source: [""],
      title: [title],
      version_number: [version_number, ""],
      volume: [volume, ""]
    }
  end

  let(:xml_path) { HykuAddons::Engine.root.join("spec", "fixtures", "orcid", "xml", "record_2.1") }
  let(:schema_file) { "work-2.1.xsd" }

  let(:work) { GenericWork.new(attributes) }
  let(:input) { work.attributes.merge(has_model: work.has_model.first).to_json }
  let(:meta) { Bolognese::Metadata.new(input: input, from: "hyku_addons_work") }
  let(:type) { "other" }
  let(:put_code) { nil }
  let(:hyrax_orcid_xml) { meta.hyrax_orcid_xml(type, put_code) }
  let(:doc) { Nokogiri::XML(hyrax_orcid_xml) }

  it "includes the module into the Metadata class" do
    expect(Bolognese::Metadata.new).to respond_to(:hyrax_orcid_xml)
    expect(Bolognese::Metadata.ancestors).to include(described_class)
  end

  describe "#hyrax_orcid_xml" do
    context "when `put_code` is provided" do
      let(:put_code) { "987654321" }

      it "includes the put-code in the root attributes" do
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
        it "doesn't includes the put-code in the root attributes" do
          expect(doc.root.attributes.keys).not_to include("put-code")
          expect(doc.root.attributes.dig("put-code")).to be_nil
        end
      end

      describe "titles" do
        it { expect(doc.xpath("//common:title/text()").to_s).to eq title }
      end

      describe "subtitles" do
        it { expect(doc.xpath("//common:subtitle/text()").to_s).to eq alt_title1 }
      end

      describe "short-description" do
        it { expect(doc.xpath("//work:short-description/text()").to_s).to eq abstract }
      end

      describe "publication-date" do
        it { expect(doc.xpath("//common:publication-date/common:year/text()").to_s).to eq published_year }
        it { expect(doc.xpath("//common:publication-date/common:month/text()").to_s).to eq "3" }
        it { expect(doc.xpath("//common:publication-date/common:day/text()").to_s).to eq "12" }
      end

      describe "creators" do
        it { expect(doc.xpath("//work:contributor").count).to eq 3 }

        it { expect(doc.xpath("//work:contributor[1]/common:contributor-orcid/common:path/text()").to_s).to eq creator1_orcid }
        it { expect(doc.xpath("//work:contributor[1]/work:credit-name/text()").to_s).to eq "#{creator1_first_name} #{creator1_last_name}" }
        it { expect(doc.xpath("//work:contributor[1]/work:contributor-attributes/work:contributor-role/text()").to_s).to eq "author" }
        it { expect(doc.xpath("//work:contributor[1]/work:contributor-attributes/work:contributor-sequence/text()").to_s).to eq "first" }

        it { expect(doc.xpath("//work:contributor[2]/common:contributor-orcid/common:path/text()").to_s).to eq "" }
        it { expect(doc.xpath("//work:contributor[2]/work:credit-name/text()").to_s).to eq "#{creator2_first_name} #{creator2_last_name}" }
        it { expect(doc.xpath("//work:contributor[2]/work:contributor-attributes/work:contributor-role/text()").to_s).to eq "author" }
        it { expect(doc.xpath("//work:contributor[2]/work:contributor-attributes/work:contributor-sequence/text()").to_s).to eq "additional" }

        it { expect(doc.xpath("//work:contributor[3]/common:contributor-orcid/common:path/text()").to_s).to eq contributor1_orcid }
        it { expect(doc.xpath("//work:contributor[3]/work:credit-name/text()").to_s).to eq "#{contributor1_first_name} #{contributor1_last_name}" }
        it { expect(doc.xpath("//work:contributor[3]/work:contributor-attributes/work:contributor-role/text()").to_s).to eq "support-staff" }
        it { expect(doc.xpath("//work:contributor[3]/work:contributor-attributes/work:contributor-sequence/text()").to_s).to eq "additional" }
      end
    end
  end
end
