# frozen_string_literal: true

require "rails_helper"
require File.expand_path("../../helpers/work_forms_context", __dir__)

RSpec.describe Hyrax::DenverBookChapterForm do
  include_context "work forms context" do
    describe "#required_fields" do
      subject { form.required_fields }

      it { is_expected.to eq %i[title creator resource_type book_title rights_statement] }
    end

    describe "#terms" do
      subject(:terms) { form.terms }

      it "sets the terms" do
        expected_terms = %i[title alt_title resource_type creator institution abstract keyword
                            subject_text org_unit date_published book_title alt_book_title edition
                            pagination alternate_identifier library_of_congress_classification
                            related_identifier isbn publisher place_of_publication license
                            rights_holder rights_statement contributor editor medium language
                            time refereed add_info]
        is_expected.to include(*expected_terms)
      end
    end
  end
end
