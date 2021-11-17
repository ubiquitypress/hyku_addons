# frozen_string_literal: true

require "rails_helper"
require File.expand_path("../../helpers/work_forms_context", __dir__)

RSpec.describe Hyrax::DenverMapForm do
  include_context "work forms context" do
    describe "#required_fields" do
      subject { form.required_fields }

      it { is_expected.to eq %i[title creator resource_type] }
    end

    describe "#terms" do
      subject(:terms) { form.terms }

      it "sets the terms" do
        expected_terms = %i[title alt_title resource_type creator abstract keyword subject_text
                            org_unit date_published alternate_identifier related_identifier
                            publisher place_of_publication event_title event_location license
                            rights_holder rights_statement contributor extent language location
                            longitude latitude georeferenced time add_info]
        is_expected.to include(*expected_terms)
      end
    end
  end
end
