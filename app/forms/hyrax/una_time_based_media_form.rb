# frozen_string_literal: true

module Hyrax
  class UnaTimeBasedMediaForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::WorkForm

    self.model_class = ::TimeBasedMedia
    add_terms %i[title resource_type creator alt_email abstract keyword subject
                 org_unit date_published related_identifier additional_links related_material
                 related_url event_title event_location event_date related_exhibition
                 related_exhibition_venue related_exhibition_date license rights_holder
                 rights_statement rights_statement_text contributor duration
                 language location longitude latitude georeferenced time irb_number
                 irb_status add_info]
    self.terms -= %i[publisher source]
    self.required_fields = %i[title resource_type creator date_published]

    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior

    def primary_terms
      %i[title resource_type creator alt_email abstract keyword subject org_unit date_published] | super
    end

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << [:title, :resource_type, :creator, :alt_email, :abstract,
                             :keyword, :subject, :org_unit, :date_published, :related_identifier,
                             :additional_links, :related_material, :related_url,
                             :event_title, :event_location, :event_date, :related_exhibition,
                             :related_exhibition_date, :license, :rights_holder,
                             :rights_statement, :rights_statement_text, :contributor,
                             :duration, :language, :location, :longitude, :latitude,
                             :georeferenced, :time, :irb_number, :irb_status, :add_info]
      end
    end
  end
end
