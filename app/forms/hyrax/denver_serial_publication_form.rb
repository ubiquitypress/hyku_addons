# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverSerialPublication`
module Hyrax
  # Generated form for DenverSerialPublication
  class DenverSerialPublicationForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::WorkForm
    self.model_class = ::DenverSerialPublication
    add_terms %i[title alt_title resource_type creator alt_email abstract keyword subject
                 org_unit date_published journal_title journal_frequency volume
                 issue pagination official_link alternate_identifier library_of_congress_classification
                 related_identifier issn eissn publisher place_of_publication licence
                 rights_holder rights_statement contributor editor medium extent
                 language location time refereed add_info]
    self.terms -= %i[related_url source]
    self.required_fields = %i[title creator resource_type licence rights_holder]

    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior

    def primary_terms
      %i[title alt_title resource_type creator] | super
    end

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << [:contributor, :extent, :language, :add_info,
                             :alternate_identifier, :library_of_congress_classification,
                             :related_identifier, :isbn, :publisher, :place_of_publication,
                             :licence, :rights_holder, :rights_statement, :editor,
                             :table_of_contents, :medium, :time, :refereed]
      end
    end
  end
end
