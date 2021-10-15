# frozen_string_literal: true
module Hyrax
  class UnaImageForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::WorkForm

    self.model_class = ::UnaImage
    add_terms %i[title alt_title resource_type creator alt_email abstract keyword
                 subject subject_text date_published date_published_text official_link
                 alternate_identifier library_of_congress_classification related_identifier
                 event_title event_location event_date related_exhibition related_exhibition_venue
                 related_exhibition_date license rights_holder rights_statement
                 rights_statement_text contributor medium extent duration is_format_of
                 language location longitude latitude georeferenced time add_info]
    self.terms -= %i[publisher]
    self.required_fields = %i[title resource_type creator]

    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior

    def primary_terms
      %i[title alt_title resource_type creator alt_email abstract keyword
         subject subject_text date_published date_published_text] | super
    end

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << [:alt_title, :alt_email, :edition, :book_title, :org_unit, :subject, :keyword,
                             :language, :location, :longitude,
                             :latitude, :license, :event_location]
      end
    end
  end
end
