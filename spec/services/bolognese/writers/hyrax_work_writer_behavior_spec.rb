# frozen_string_literal: true

require "rails_helper"

RSpec.describe Bolognese::Writers::HyraxWorkWriterBehavior do
  let(:creator_given_name) { "Sebastian" }
  let(:creator_family_name) { "Hageneuer" }
  let(:creator_orcid) { "0000-0003-0652-4625" }
  let(:creator) do
    {
      creator_name_type: "Personal",
      creator_given_name: creator_given_name,
      creator_family_name: creator_family_name,
      creator_orcid: "https://sandbox.orcid.org/#{creator_orcid}"
    }
  end
  let(:contributor_given_name) { "Jannet" }
  let(:contributor_family_name) { "Gnitset" }
  let(:contributor_orcid) { "0000-1234-5109-3702" }
  let(:contributor_role) { "Other" }
  let(:contributor) do
    {
      contributor_name_type: "Personal",
      contributor_given_name: contributor_given_name,
      contributor_family_name: contributor_family_name,
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

  describe "#creators" do
    context "when a personal creator is present" do
      it "returns the correct result" do
        creator_result = [{
          "name" => "#{creator_family_name}, #{creator_given_name}",
          "givenName" => creator_given_name.to_s,
          "familyName" => creator_family_name.to_s,
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

  describe "#contributors" do
    context "when a personal contributor is present" do
      it "returns the correct result" do
        contributor_result = [{
          "name" => "#{contributor_family_name}, #{contributor_given_name}",
          "givenName" => contributor_given_name.to_s,
          "familyName" => contributor_family_name.to_s,
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

  describe "#cleanup_author" do
    context "when the author is JSON" do
      let(:author) { [creator].to_json }

      it "performs no changes and returns the JSON" do
        expect(meta.send(:cleanup_author, author)).to eq author
      end
    end

    context "when the author is not JSON" do
      let(:author) { "#{creator_family_name}, #{creator_given_name}" }

      it "updates the string" do
        expect(meta.send(:cleanup_author, author)).to eq author
      end
    end
  end

  describe "#json?" do
    context "when the argument is JSON" do
      let(:author) { [creator].to_json }

      it "returns true" do
        expect(meta.send(:json?, author)).to eq true
      end
    end

    context "when the author is not JSON" do
      let(:author) { "#{creator_family_name}, #{creator_given_name}" }

      it "is not true" do
        expect(meta.send(:json?, author)).to eq false
      end
    end
  end
end
