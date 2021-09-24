# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::BookPresenter do
  let(:presenter) { described_class.new(solrdoc, nil, nil) }
  let(:work) { Book.new }
  let(:solrdoc) { SolrDocument.new(work.to_solr, nil) }

  describe "accessors" do
    it "delegates methods to the presenter" do
      described_class.delegated_methods.each { |property| expect(presenter).to respond_to(property) }
    end
  end
end
