# frozen_string_literal: true
module Hyrax
  class UnaArchivalItemForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::WorkForm

    self.model_class = ::UnaArchivalItem
    add_terms %i[title resource_type creator alt_email abstract
                 keyword subject date_published alternate_identifier
                 library_of_congress_classification dewey related_identifier
                 adapted_from additional_links related_material related_url source
                 isbn issn eissn publisher place_of_publication citation funder
                 project_name fndr_project_ref funding_description event_title
                 event_location event_date related_exhibition related_exhibition_venue
                 related_exhibition_date license rights_holder rights_statement
                 rights_statement_text contributor medium extent duration is_format_of
                 language prerequisites location longitude latitude georeferenced
                 time irb_number irb_status add_info]

    self.required_fields = %i[title resource_type creator]
    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior

    def primary_terms
      %i[title resource_type creator alt_email abstract keyword subject date_published] | super
    end

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << [:title, :resource_type, :creator, :alt_email, :abstract,
                             :keyword, :subject, :date_published, :alternate_identifier,
                             :library_of_congress_classification, :dewey, :related_identifier,
                             :adapted_from, :additional_links, :related_material,
                             :related_url, :source, :isbn, :issn, :eissn, :publisher,
                             :place_of_publication, :citation, :funder, :project_name,
                             :fndr_project_ref, :funding_description, :event_title,
                             :event_location, :event_date, :related_exhibition,
                             :related_exhibition_date, :license, :rights_holder,
                             :rights_statement, :rights_statement_text, :contributor,
                             :medium, :extent, :duration, :is_format_of, :language,
                             :prerequisites, :location, :longitude, :latitude,
                             :georeferenced, :time, :irb_number, :irb_status,
                             :related_exhibition_venue, :add_info]
      end
    end
  end
end
