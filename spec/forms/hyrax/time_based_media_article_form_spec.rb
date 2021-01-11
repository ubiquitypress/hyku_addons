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
      }.merge(common_params, editor_params, event_params, event_date_params)
    end

    it 'permits parameters' do
      check_common_fields_presence
      check_attribute_group_presence(:event_date, [:event_date_year, :event_date_month, :event_date_day])
      %w[event_title event_location].each do |attr|
        expect(model_attributes[attr]).to eq attr
      end
    end
  end
end
