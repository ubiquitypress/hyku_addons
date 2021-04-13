# frozen_string_literal: true

require 'spec_helper'
require 'hyrax/doi/spec/shared_specs'

RSpec.describe Hyrax::GenericWorkPresenter do
  let(:presenter) { described_class.new(solr_document, nil, nil) }
  let(:presenter_class) { described_class }
  let(:solr_document) { SolrDocument.new(work.to_solr) }
  let(:solr_document_class) { SolrDocument }
  let(:work) { build(:generic_work) }

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
end
