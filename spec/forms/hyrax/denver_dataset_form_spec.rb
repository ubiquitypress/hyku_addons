# frozen_string_literal: true

require 'rails_helper'
require File.expand_path('../../helpers/work_forms_context', __dir__)

RSpec.describe Hyrax::DenverDatasetForm do
  include_context 'work forms context' do

    describe "#required_fields" do
      subject { form.required_fields }

      it { is_expected.to eq %i[title creator resource_type license] }
    end

    describe "#terms" do
      subject(:terms) { form.terms }

      it "sets the terms" do
        expected_terms = %i[title alt_title resource_type creator institution abstract keyword
                            subject_text org_unit date_published version_number alternate_identifier
                            related_identifier license contributor medium extent language location
                            longitude latitude time add_info]
        is_expected.to include(*expected_terms)
      end
    end
  end
end
