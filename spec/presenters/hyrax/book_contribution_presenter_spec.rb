# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::BookContributionPresenter do
  let(:presenter) { described_class.new(solrdoc, nil, nil) }
  let(:work) { BookContribution.new }
  let(:solrdoc) { SolrDocument.new(work.to_solr, nil) }

  describe 'accessors' do
    it 'defines accessors' do
      described_class.delegated_methods.each { |property| expect(presenter).to respond_to(property) }
    end

    it 'defines isbns' do
      expect(presenter).to respond_to(:isbns)
    end
  end
end
