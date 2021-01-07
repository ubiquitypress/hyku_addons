# frozen_string_literal: true
require 'rails_helper'
require File.expand_path('../../helpers/work_forms_context', __dir__)

RSpec.describe Hyrax::TimeBasedMediaArticleForm do
  include_context 'work forms context' do
    describe "#required_fields" do
      subject { form.required_fields }

      it { is_expected.to eq %i[title resource_type creator institution license] }
    end
  end

  describe "#terms" do
    subject { form.primary_terms }

    it { is_expected.to eq %i[title resource_type creator institution license] }
  end

  describe ".model_attributes" do
    subject(:model_attributes) { described_class.model_attributes(params) }

    let(:params) { ActionController::Parameters.new(attributes) }
    let(:attributes) do
      {
        media: 'media',
        duration: 'duration',
        version: 'version',
        publisher: 'publisher',
        place_of_publication: 'place_of_publication',
        official_url: 'official_url',
        related_url: 'related_url'
      }.merge(common_params, date_submitted_params, date_accepted_params, editor_params, alternate_identifier_params,
              event_params, related_identifier_params)
    end

    it 'permits parameters' do
      check_common_fields_presence
      check_attribute_group_presence(:date_submitted, [:date_submitted_year, :date_submitted_month, :date_submitted_day])
      check_attribute_group_presence(:date_accepted,  [:date_accepted_year, :date_accepted_month, :date_accepted_day])
      check_attribute_group_presence(:alternate_identifier, [:alternate_identifier, :alternate_identifier_type])
      check_attribute_group_presence(:related_identifier, [:related_identifier, :related_identifier_type, :relation_type])
      check_attribute_group_presence(:event, [:event_title, :event_location])
    end
  end
end
