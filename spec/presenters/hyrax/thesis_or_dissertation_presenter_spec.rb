# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::ThesisOrDissertationPresenter do
  let(:presenter) { described_class.new(solrdoc, nil, nil) }
  let(:work) { ThesisOrDissertation.new }
  let(:solrdoc) { SolrDocument.new(work.to_solr, nil) }

  describe 'accessors' do
    it 'defines accessors' do
      described_class.delegated_methods.each { |property| expect(presenter).to respond_to(property) }
    end
  end
end
