# frozen_string_literal: true
# TODO: flaky tests. Need fixing.
RSpec.xdescribe Hyrax::DOI::DataCiteRegistrar do
  let(:registrar) { described_class.new }
  let(:draft_doi) { "#{prefix}/draft-doi" }
  let(:prefix) { "10.1234" }
  let(:work) { create(:work, attributes) }
  let(:attributes) do
    {
      title: [title],
      creator: [creator]
    }
  end
  let(:title) { "Moomin" }
  let(:creator) do
    [
      {
        "creator_given_name" => creator_given_name,
        "creator_family_name" => creator_family_name,
        "creator_name_type" => "Personal",
        "creator_profile_visibility" => profile_visibility
      }
    ].to_json
  end
  let(:creator_family_name) { "Johnny" }
  let(:creator_given_name) { "Smithy" }

  describe "#work_to_datacite_xml" do
    let(:datacite_xml) { registrar.send(:work_to_datacite_xml, work) }
    let(:doc) { Nokogiri::XML(datacite_xml) }

    context "when the visibility is set correctly" do
      let(:profile_visibility) { "closed" }

      it "converts the creator block into the correct format" do
        expect(doc.css("creators creator creatorName").text).to eq "#{creator_family_name}, #{creator_given_name}"
        expect(doc.css("creators creator givenName").text).to eq creator_given_name
        expect(doc.css("creators creator familyName").text).to eq creator_family_name
      end
    end

    context "when the visibility is not set correctly" do
      let(:profile_visibility) { false }

      it "converts the creator block into the correct format" do
        expect(doc.css("creators creator creatorName").text).to eq "#{creator_family_name}, #{creator_given_name}"
        expect(doc.css("creators creator givenName").text).to eq creator_given_name
        expect(doc.css("creators creator familyName").text).to eq creator_family_name
      end
    end
  end
end
