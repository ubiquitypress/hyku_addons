# frozen_string_literal: true
require "rails_helper"
require File.expand_path("../../support/shared_contexts/work_forms_context", __dir__)

RSpec.describe Hyrax::TimeBasedMediaForm do
  include_context "work forms context" do
    describe "#required_fields" do
      subject { form.required_fields }

      it { is_expected.to eq %i[title resource_type creator institution date_published] }
    end
  end

  describe "#terms" do
    subject { form.terms }

    it "sets the terms" do
      expected_terms = %i[title resource_type abstract add_info alt_title alternate_identifier event_title
                          event_location event_date contributor creator date_accepted date_published date_submitted
                          dewey doi fndr_project_ref funder institution keyword language
                          library_of_congress_classification license official_link org_unit place_of_publication
                          project_name publisher related_identifier related_url rights_holder rights_statement editor]
      is_expected.to include(*expected_terms)
    end
  end

  describe ".model_attributes" do
    subject(:model_attributes) { described_class.model_attributes(params) }

    let(:params) { ActionController::Parameters.new(attributes) }
    let(:attributes) do
      {
        media: "media",
        duration: "duration",
        version: "version",
        publisher: "publisher",
        place_of_publication: "place_of_publication",
        official_url: "official_url",
        related_url: "related_url"
      }.merge(common_params, editor_params, event_params, event_date_params)
    end

    it "permits parameters" do
      check_common_fields_presence
      check_attribute_group_presence(:event_date, [:event_date_year, :event_date_month, :event_date_day])
      %w[event_title event_location].each do |attr|
        expect(model_attributes[attr]).to eq attr
      end
    end
  end
end
