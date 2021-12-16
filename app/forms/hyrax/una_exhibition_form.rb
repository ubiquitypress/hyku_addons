# frozen_string_literal: true
module Hyrax
  class UnaExhibitionForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::WorkForm

    self.model_class = ::UnaExhibition
    add_terms %i[title alt_title resource_type creator alt_email abstract keyword
                 subject subject_text official_link alternate_identifier citation
                 funder project_name fndr_project_ref
                 event_title event_location event_date related_exhibition
                 related_exhibition_venue related_exhibition_date
                 license rights_holder rights_statement rights_statement_text contributor
                 medium extent duration is_format_of language location longitude
                 latitude georeferenced time refereed irb_number irb_status add_info]
    self.terms -= %i[source publisher related_url]
    self.required_fields = %i[title resource_type creator]

    include HykuAddons::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior

    def primary_terms
      %i[title alt_title resource_type creator alt_email abstract keyword subject] | super
    end

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << [:title, :alt_title, :resource_type, :creator,
                             :alt_email, :abstract, :keyword,
                             :subject, :subject_text, :official_link, :alternate_identifier,
                             :citation, :funder, :project_name, :fndr_project_ref,
                             :event_title, :event_location, :event_date,
                             :related_exhibition, :related_exhibition_date, :license,
                             :rights_holder, :rights_statement, :rights_statement_text,
                             :contributor, :medium, :extent, :duration, :is_format_of,
                             :language, :location, :longitude, :latitude, :georeferenced,
                             :time, :refereed, :irb_number, :irb_status, :add_info]
      end
    end
  end
end
