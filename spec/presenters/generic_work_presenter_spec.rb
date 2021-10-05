# frozen_string_literal: true

require 'spec_helper'
require 'hyrax/doi/spec/shared_specs'

RSpec.describe Hyrax::GenericWorkPresenter do
  let(:presenter) { described_class.new(solr_document, nil, nil) }
  let(:presenter_class) { described_class }
  let(:solr_document) { SolrDocument.new(work.to_solr) }
  let(:solr_document_class) { SolrDocument }
  let(:work) { build(:generic_work) }

  let(:abstract) { "Swedish comic about the adventures of the residents of Moominvalley." }
  let(:add_info) { "Nothing to report" }
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
  let(:keyword) { "Lighthouses" }
  let(:title) { "Moomin" }

  let(:attributes) do
    {
      abstract: abstract,
      add_info: add_info,
      contributor: [[contributor1].to_json],
      creator: [[creator1, creator2].to_json],
      keyword: [keyword],
      title: [title]
    }
  end

  it_behaves_like 'a DOI-enabled presenter'
  it_behaves_like 'a DataCite DOI-enabled presenter'

  describe 'accessors' do
    it 'defines accessors' do
      described_class.delegated_methods.each { |property| expect(presenter).to respond_to(property) }
    end

    it 'defines isbns' do
      expect(presenter).to respond_to(:isbns)
    end
  end

  describe "#export_as_ris" do
    it "is a defined method" do
      expect(presenter).to respond_to(:export_as_ris)
    end

    it "returns a non empty string" do
      expect(presenter.export_as_ris).to be_present
      expect(presenter.export_as_ris).to be_a(String)
    end

    it "returns a string in the RIS format" do
      expect(presenter.export_as_ris).to include("T1  - #{presenter.title.first}")
    end
  end

  describe "#creator" do
    let(:work) { GenericWork.new(attributes) }
    let(:presenter) { described_class.new(work, nil, nil) }

    it "returns a JSON string" do
      expect(presenter.creator.first).to be_a(String)
      expect { JSON.parse(presenter.creator.first) }.not_to raise_error
    end
  end

  describe "#contributor" do
    let(:work) { GenericWork.new(attributes) }
    let(:presenter) { described_class.new(work, nil, nil) }

    it "returns a JSON string" do
      expect(presenter.contributor.first).to be_a(String)
      expect { JSON.parse(presenter.contributor.first) }.not_to raise_error
    end
  end
end
