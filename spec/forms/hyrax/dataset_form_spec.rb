# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work BookContribution`
require "rails_helper"
require File.expand_path("../../helpers/work_forms_context", __dir__)

RSpec.describe Hyrax::DatasetForm do
  include_context "work forms context" do
    describe "#required_fields" do
      subject { form.required_fields }

      it { is_expected.to eq %i[title resource_type creator institution date_published] }
    end

    describe "#terms" do
      subject(:terms) { form.terms.sort }

      it do
        terms = %i[title resource_type creator alt_title contributor rendering_ids abstract date_published
                   institution org_unit project_name funder fndr_project_ref version_number publisher place_of_publication
                   date_accepted date_submitted official_link related_url language license rights_statement rights_holder
                   doi alternate_identifier related_identifier refereed keyword dewey library_of_congress_classification
                   add_info]
        expect(terms.all? { |t| terms.include?(t) }).to eq true
      end
    end

    describe ".model_attributes" do
      subject(:model_attributes) { described_class.model_attributes(params) }

      let(:params) { ActionController::Parameters.new(attributes) }
      let(:attributes) do
        {
          version_number: "version_number",
          place_of_publication: "place_of_publication"
        }.merge(common_params)
      end

      it "permits parameters" do
        check_common_fields_presence
        %w[version_number place_of_publication].each do |attr|
          expect(model_attributes[attr]).to eq attr
        end
      end
    end
  end
end
