# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::ArticlePresenter do
  let(:presenter) { described_class.new(work, nil, nil) }
  let(:work) { build(:generic_work) }

  let(:additional_properties) do
    [:volume, :pagination, :issn, :eissn, :contributor_display, :publisher, :official_link,
     :journal_title, :issue, :article_num, :alternative_journal_title,
     :institution, :org_unit, :refereed, :funder, :fndr_project_ref, :add_info, :date_published,
     :date_accepted, :date_submitted, :project_name, :rights_holder, :place_of_publication,
     :abstract, :alternate_identifier, :related_identifier, :creator, :creator_json,
     :library_of_congress_classification, :alt_title, :dewey,
     :title, :date_created, :description]
  end

  describe 'accessors' do
    it 'defines accessors' do
      additional_properties.each { |property| expect(presenter).to respond_to(property) }
    end
  end
end
