# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::TimeBasedMediaArticlePresenter do
  let(:presenter) { described_class.new(work, nil, nil) }
  let(:work) { build(:generic_work) }

  let(:additional_properties) do
    %i[title resource_type creator alt_title contributor rendering_ids abstract date_published media
       duration institution org_unit project_name funder fndr_project_ref event_title event_location event_date
       editor publisher place_of_publication date_accepted date_submitted
       official_link related_url related_exhibition related_exhibition_venue related_exhibition_date language
       license rights_statement rights_holder doi alternate_identifier related_identifier refereed keyword
       dewey library_of_congress_classification add_info]
  end

  describe 'accessors' do
    it 'defines accessors' do
      additional_properties.each { |property| expect(presenter).to respond_to(property) }
    end
  end
end
