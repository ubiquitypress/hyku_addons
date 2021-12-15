# frozen_string_literal: true

require "rails_helper"

RSpec.describe HykuAddons::OrcidHelperBehavior, type: :helper do
  include Devise::Test::ControllerHelpers

  it "is loaded" do
    expect(HykuAddons::HelperBehavior.ancestors).to include(described_class)
  end

  it "is loaded first" do
    items = [described_class, Hyrax::Orcid::HelperBehavior, Hyrax::Orcid::JsonFieldHelper]
    expect(HykuAddons::HelperBehavior.ancestors.select { |item| items.include?(item) }.first).to eq described_class
  end

  describe "#participant_to_string" do
    let(:helper) { _view }

    let(:title) { "Moomin" }
    let(:description) { "Swedish comic about the adventures of the residents of Moominvalley." }
    let(:keyword) { "Lighthouses" }
    let(:resource_type) { "Book" }
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
    let(:work_attributes) do
      {
        title: [title],
        resource_type: [resource_type],
        creator: [[creator1, creator2].to_json],
        contributor: [[contributor1].to_json],
        description: [description],
        keyword: [keyword],
        visibility: "open"
      }
    end
    let(:work) { build_stubbed(:work, work_attributes) }

    it "reads the creators" do
      expect(helper.participant_to_string(:creator, work.creator)).to eq "Sebastian Hageneuer, Johnny Testing"
    end

    it "reads the contributors" do
      expect(helper.participant_to_string(:contributor, work.contributor)).to eq "Jannet Gnitset"
    end
  end
end
