# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverDataset`
module Hyrax
  # Generated form for DenverDataset
  class DenverDatasetForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::WorkForm
    self.model_class = ::DenverDataset
    add_terms %i[title alt_title resource_type creator institution abstract keyword
                 subject_text org_unit date_published version_number alternate_identifier
                 related_identifier license contributor medium extent language location
                 longitude latitude time add_info]
    self.terms -= %i[related_url publisher source subject]
    self.required_fields = %i[title creator resource_type license]

    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior

    def primary_terms
      %i[title alt_title resource_type creator] | super
    end

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params <<  [:title, :alt_title, :resource_type, :creator, :institution,
                              :abstract, :keyword, :subject_text, :org_unit, :date_published,
                              :version_number, :alternate_identifier, :related_identifier,
                              :license, :contributor, :medium, :extent, :language,
                              :location, :longitude, :latitude, :time, :add_info]

      end
    end
  end
end
