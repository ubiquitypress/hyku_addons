# frozen_string_literal: true

require "rails_helper"

RSpec.describe Bolognese::Writers::HyraxWorkWriterBehavior do
  let(:creator_first_name) { "Sebastian" }
  let(:creator_last_name) { "Hageneuer" }
  let(:creator_orcid) { "0000-0003-0652-4625" }
  let(:creator) do
    {
      creator_name_type: "Personal",
      creator_given_name: creator_first_name,
      creator_family_name: creator_last_name,
      creator_orcid: "https://sandbox.orcid.org/#{creator_orcid}"
    }
  end
  let(:contributor_first_name) { "Jannet" }
  let(:contributor_last_name) { "Gnitset" }
  let(:contributor_orcid) { "0000-1234-5109-3702" }
  let(:contributor_role) { "Other" }
  let(:contributor) do
    {
      contributor_name_type: "Personal",
      contributor_given_name: contributor_first_name,
      contributor_family_name: contributor_last_name,
      contributor_orcid: "https://orcid.org/#{contributor_orcid}"
    }
  end
  let(:resource_type) { "Book" }
  let(:title) { "Moomin" }
  let(:attributes) do
    {
      creator: [[creator].to_json],
      contributor: [[contributor].to_json],
      resource_type: [resource_type, ""],
      title: [title]
    }
  end
  let(:work) { GenericWork.new(attributes) }
  let(:input) { work.attributes.merge(has_model: work.has_model.first).to_json }
  let(:meta) { Bolognese::Metadata.new(input: input, from: "hyrax_work") }
  let(:doc) { Nokogiri::XML(meta.datacite) }

  describe "creators" do
    context "when a personal creator is present" do
      it "returns the correct result" do
        creator_result = [{
          "name" => "#{creator_last_name}, #{creator_first_name}",
          "givenName" => creator_first_name.to_s,
          "familyName" => creator_last_name.to_s,
          "nameIdentifiers" => [{ "nameIdentifier" => "https://sandbox.orcid.org/#{creator_orcid}", "nameIdentifierScheme" => "orcid" }]
        }]
        expect(meta.creators).to eq(creator_result)
      end
    end

    context "when an organizational creator is present" do
      let(:creator_organization_name) { "Test Org Name" }
      let(:creator) do
        {
          creator_name_type: "Organizational",
          creator_organization_name: creator_organization_name
        }
      end

      it "returns the correct result" do
        creator_result = [{ "name" => creator_organization_name, "nameIdentifiers" => [], "affiliation" => [] }]
        expect(meta.creators).to eq(creator_result)
      end
    end
  end

  describe "contributors" do
    context "when a personal contributor is present" do
      it "returns the correct result" do
        contributor_result = [{
          "name" => "#{contributor_last_name}, #{contributor_first_name}",
          "givenName" => contributor_first_name.to_s,
          "familyName" => contributor_last_name.to_s,
          "nameIdentifiers" => [{ "nameIdentifier" => "https://orcid.org/#{contributor_orcid}", "nameIdentifierScheme" => "orcid" }]
        }]
        expect(meta.contributors).to eq(contributor_result)
      end
    end

    context "when an organizational contributor is present" do
      let(:contributor_organization_name) { "Test Org Name" }
      let(:contributor) do
        {
          contributor_name_type: "Organizational",
          contributor_organization_name: contributor_organization_name
        }
      end

      it "returns the correct result" do
        contributor_result = [{ "name" => contributor_organization_name, "nameIdentifiers" => [], "affiliation" => [] }]
        expect(meta.contributors).to eq(contributor_result)
      end
    end
  end
end
