# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work BookContribution`
require 'rails_helper'
require File.expand_path('../../helpers/work_forms_context', __dir__)

RSpec.describe Hyrax::ExhibitionItemForm do
  include_context 'work forms context' do
    describe "#required_fields" do
      subject { form.required_fields }

      it { is_expected.to eq [:title, :resource_type, :creator, :institution, :date_published] }
    end

    describe "#terms" do
      subject { form.terms }

      it do
        expected_terms = %i[title resource_type creator alt_title contributor rendering_ids abstract date_published event_title event_location event_date
                            institution org_unit project_name funder fndr_project_ref series_name editor media version_number
                            publisher place_of_publication isbn issn eissn date_accepted date_submitted official_link related_url
                            language license rights_statement rights_holder doi alternate_identifier related_identifier refereed
                            keyword dewey library_of_congress_classification add_info pagination related_exhibition related_exhibition_venue
                            related_exhibition_date]
        is_expected.to include(*expected_terms)
      end
    end

    describe ".model_attributes" do
      subject(:model_attributes) { described_class.model_attributes(params) }

      let(:params) { ActionController::Parameters.new(attributes) }
      let(:attributes) do
        common_params.merge(editor_params, event_params, event_date_params)
      end

      it 'permits parameters' do
        check_common_fields_presence
        check_attribute_group_presence(:editor, [:editor_isni, :editor_orcid, :editor_family_name, :editor_given_name])
        check_attribute_group_presence(:event_date, [:event_date_year, :event_date_month, :event_date_day])
        %w[event_title event_location].each do |attr|
          expect(model_attributes[attr]).to eq attr
        end
      end
    end
  end
end
