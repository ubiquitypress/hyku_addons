# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::ArticlePresenter do
  let(:presenter) { described_class.new(solrdoc, nil, nil) }
  let(:work) { Article.new }
  let(:solrdoc) { SolrDocument.new(work.to_solr, nil) }

  describe 'accessors' do
    it 'defines accessors' do
      described_class.delegated_methods.each { |property| expect(presenter).to respond_to(property) }
    end

    it "doesn't respond to generic work delegated methods" do
      difference = Hyrax::GenericWorkPresenter.delegated_methods - presenter.class.delegated_methods
      difference.each { |property| expect(presenter).not_to respond_to(property) }
    end
  end
end
