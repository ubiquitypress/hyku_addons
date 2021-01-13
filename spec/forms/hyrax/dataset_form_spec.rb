# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work BookContribution`
require 'rails_helper'
require File.expand_path('../../helpers/work_forms_context', __dir__)

RSpec.describe Hyrax::DatasetForm do
  include_context 'work forms context' do
    describe "#required_fields" do
      subject { form.required_fields }

      it { is_expected.to eq [:title, :resource_type, :creator, :institution] }
    end

    describe "#terms" do
      subject { form.terms }

      it do
        is_expected.not_to include(:media, :duration, :journal_title, :edition, :alternative_journal_title, :event_title,
                                   :event_location, :event_date, :pagination, :issue, :article_number, :current_he_institution,
                                   :eisbn, :editor, :issn, :related_exhibition, :related_exhibition_venue, :qualification_name,
                                   :isbn, :qualification_level)
      end
    end

    describe ".model_attributes" do
      subject(:model_attributes) { described_class.model_attributes(params) }

      let(:params) { ActionController::Parameters.new(attributes) }
      let(:attributes) do
        {
            version: 'version',
            place_of_publication: 'place_of_publication',
        }.merge(common_params)
      end

      it 'permits parameters' do
        check_common_fields_presence
        %w[version place_of_publication].each do |attr|
          expect(model_attributes[attr]).to eq attr
        end
      end
    end
  end
end
