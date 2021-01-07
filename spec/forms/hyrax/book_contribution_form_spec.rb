# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work BookContribution`
require 'rails_helper'
require File.expand_path('../../helpers/work_forms_context', __dir__)

RSpec.describe Hyrax::BookContributionForm do
  include_context 'work forms context' do
    describe "#required_fields" do
      subject { form.required_fields }

      it { is_expected.to eq [:title, :resource_type, :creator, :institution] }
    end

    describe "#terms" do
      subject { form.terms }

      it do
        is_expected.not_to include(:media, :duration, :event_title, :event_location, :event_date, :journal_title,
                                   :alternative_journal_title, :version, :issue, :article_number, :current_he_institution,
                                   :related_exhibition, :related_exhibition_venue, :qualification_name, :qualification_level)
      end
    end

    describe ".model_attributes" do
      subject(:model_attributes) { described_class.model_attributes(params) }

      let(:params) { ActionController::Parameters.new(attributes) }
      let(:attributes) do
        common_params.merge(date_submitted_params, date_accepted_params, editor_params, alternate_identifier_params,
                            related_identifier_params)
      end

      it 'permits parameters' do
        check_common_fields_presence
        check_attribute_group_presence(:date_submitted, [:date_submitted_year, :date_submitted_month, :date_submitted_day])
        check_attribute_group_presence(:date_accepted, [:date_accepted_year, :date_accepted_month, :date_accepted_day])
        # check_attribute_group_presence(:editor, [:editor_isni, :editor_orcid, :editor_family_name, :editor_given_name, :editor_organisational_name, :editor_institutional_relationship])
        check_attribute_group_presence(:editor, [:editor_isni, :editor_orcid, :editor_family_name, :editor_given_name])
        check_attribute_group_presence(:alternate_identifier, [:alternate_identifier, :alternate_identifier_type])
        check_attribute_group_presence(:related_identifier, [:related_identifier, :related_identifier_type, :relation_type])
      end
    end
  end
end
