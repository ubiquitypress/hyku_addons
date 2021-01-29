# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Hyrax::ReportPresenter do
  let(:presenter) { described_class.new(work, nil, nil) }
  let(:work) { build(:generic_work) }

  let(:additional_properties) do
    %i[title resource_type creator_display alt_title contributor_display rendering_ids abstract
       date_published institution org_unit project_name funder fndr_project_ref series_name
       editor_display volume edition publisher place_of_publication isbn issn eissn date_accepted
       date_submitted official_link related_url language license rights_statement rights_holder doi
       alternate_identifier related_identifier refereed keyword dewey
       library_of_congress_classification add_info pagination]
  end

  describe 'accessors' do
    it 'defines accessors' do
      additional_properties.each { |property| expect(presenter).to respond_to(property) }
    end
  end
end
