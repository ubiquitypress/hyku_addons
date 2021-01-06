# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work Article`
require 'rails_helper'
require File.expand_path('../../helpers/work_forms_context', __dir__)

RSpec.describe Hyrax::ArticleForm do
  include_context 'work forms context' do
    describe "#required_fields" do
      subject { form.required_fields }

      it { is_expected.to eq [:title, :resource_type, :creator, :institution] }
    end

    describe "#terms" do
      subject { form.terms }

      it do
        is_expected.not_to include(:media, :duration, :event_title, :event_location, :event_date, :series_name, :book_title, :editor, :edition,
                                   :alternative_journal_title, :version, :issue, :article_number, :current_he_institution,
                                   :related_exhibition, :related_exhibition_venue, :qualification_name, :qualification_level)
      end
    end

    describe ".model_attributes" do
      subject(:model_attributes) { described_class.model_attributes(params) }

      let(:params) { ActionController::Parameters.new(attributes) }
      let(:attributes) do
        {
            title: ['foo'],
            rendering_ids: ['file-set-id'],
            abstract: 'abstract',
        }.merge(creator_params, contributor_params, date_published_params, date_submitted_params, date_accepted_params,
                funder_params, alternate_identifier_params, related_identifier_params)
      end

      it 'permits parameters' do
        expect(model_attributes['title']).to eq ['foo']
        expect(model_attributes['rendering_ids']).to eq ['file-set-id']
        expect(model_attributes['abstract']).to eq 'abstract'
        check_attribute_group_presence(:creator, [:creator_organization_name, :creator_given_name,
                                                  :creator_family_name, :creator_name_type, :creator_orcid, :creator_isni, :creator_ror, :creator_grid,
                                                  :creator_wikidata, :creator_institutional_relationship])
        check_attribute_group_presence(:contributor, [:contributor_organization_name, :contributor_given_name,
                                                      :contributor_family_name, :contributor_name_type, :contributor_orcid, :contributor_isni, :contributor_ror, :contributor_grid,
                                                      :contributor_wikidata, :contributor_type, :contributor_institutional_relationship])
        check_attribute_group_presence(:date_published, [:date_published_year, :date_published_month, :date_published_day])
        check_attribute_group_presence(:date_submitted, [:date_submitted_year, :date_submitted_month, :date_submitted_day])
        check_attribute_group_presence(:date_accepted,  [:date_accepted_year, :date_accepted_month, :date_accepted_day])
        check_attribute_group_presence(:funder, [:funder_name, :funder_doi, :funder_isni, :funder_ror, :funder_award])
        check_attribute_group_presence(:alternate_identifier, [:alternate_identifier, :alternate_identifier_type])
        check_attribute_group_presence(:related_identifier, [:related_identifier, :related_identifier_type, :relation_type] )
      end

    end
  end
end
