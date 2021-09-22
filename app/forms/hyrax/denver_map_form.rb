# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverMap`
module Hyrax
  # Generated form for DenverMap
  class DenverMapForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::WorkForm
    self.model_class = ::DenverMap
    add_terms %i[title alt_title resource_type creator abstract keyword subject_text
                 org_unit date_published alternate_identifier related_identifier
                 publisher place_of_publication event_title event_location license
                 rights_holder rights_statement contributor extent language location
                 longitude latitude georeferenced time add_info]
    self.terms -= %i[related_url publisher source subject]
    self.required_fields = %i[title creator resource_type]

    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior

    def primary_terms
      %i[title alt_title resource_type creator] | super
    end

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << [:alternate_identifier, :related_identifier, :related_exhibition,
                             :related_exhibition_venue, :related_exhibition_date, :license, :rights_holder,
                             :rights_statement, :contributor, :extent, :language, :location, :longitude, :latitude,
                             :georeferenced, :add_info, :irb_number, :mesh]
      end
    end
  end
end
