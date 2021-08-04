# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverMultimedia`
module Hyrax
  # Generated form for DenverMultimedia
  class DenverMultimediaForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::WorkForm
    self.model_class = ::DenverMultimedia
    add_terms %i[title alt_title resource_type creator abstract keyword subject
                 date_published alternate_identifier library_of_congress_classification
                 related_identifier publisher place_of_publication event_title event_location
                 license rights_holder rights_statement contributor medium duration
                 language add_info]
    self.terms -= %i[related_url source]
    self.required_fields = %i[title creator resource_type]

    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior

    def primary_terms
      %i[title alt_title resource_type creator] | super
    end

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << [:alternate_identifier, :related_identifier, :licence, :rights_holder,
                             :rights_statement, :contributor, :medium, :language, :duration, :add_info,
                             :place_of_publication, :library_of_congress_classification, :event_title,
                             :event_location]
      end
    end
  end
end