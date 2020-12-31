# Generated via
#  `rails generate hyrax:work BookContribution`
require 'rails_helper'

RSpec.describe Hyrax::BookContributionPresenter do
  let(:presenter) { described_class.new(work, nil, nil) }
  let(:work) { build(:generic_work) }

  let(:additional_properties) do
    [
        :volume, :pagination, :issn, :eissn, :official_link, :series_name, :edition,
        :event_title, :event_date, :event_location, :book_title, :journal_title,
        :issue, :article_num, :isbn, :media, :related_exhibition, :related_exhibition_date,
        :version, :version_number, :alternative_journal_title, :related_exhibition_venue,
        :current_he_institution, :qualification_name, :qualification_level, :duration, :editor,
        :institution, :org_unit, :refereed, :funder, :fndr_project_ref, :add_info, :date_published,
        :date_accepted, :date_submitted, :project_name, :rights_holder, :place_of_publication,
        :abstract, :alternate_identifier, :related_identifier, :creator_display,
        :library_of_congress_classification, :alt_title, :dewey, :collection_id, :collection_names,
        :title, :date_created, :description
    ]
  end

  describe 'accessors' do
    it 'defines accessors' do
      additional_properties.each { |property| expect(presenter).to respond_to(property) }
    end

    it 'defines isbns' do
      expect(presenter).to respond_to(:isbns)
    end
  end
end
