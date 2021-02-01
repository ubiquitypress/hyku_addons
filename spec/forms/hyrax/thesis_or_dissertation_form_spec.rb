# frozen_string_literal: true

require 'rails_helper'
require File.expand_path('../../helpers/work_forms_context', __dir__)

RSpec.describe Hyrax::ThesisOrDissertationForm do
  include_context 'work forms context' do
    describe "#required_fields" do
      subject { form.required_fields }

      it {
        fields = %i[title resource_type creator date_published institution qualification_level qualification_name]
        is_expected.to eq fields
      }
    end

    describe "#terms" do
      subject(:terms) { form.terms }

      it "sets the terms" do
        expected_terms = %i[title resource_type creator alt_title contributor rendering_ids abstract date_published
                            institution org_unit project_name funder fndr_project_ref publisher current_he_institution
                            date_accepted date_submitted official_link related_url language license rights_statement rights_holder
                            doi qualification_name qualification_level alternate_identifier related_identifier refereed keyword
                            dewey library_of_congress_classification add_info pagination]

        is_expected.to include(*expected_terms)
      end
    end

    describe ".model_attributes" do
      subject(:model_attributes) { described_class.model_attributes(params) }

      let(:params) { ActionController::Parameters.new(attributes) }
      let(:attributes) do
        common_params
      end

      it 'permits the default parameters' do
        check_common_fields_presence
      end
    end
  end
end
