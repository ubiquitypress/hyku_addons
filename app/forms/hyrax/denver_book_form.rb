# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverBook`
module Hyrax
  # Generated form for DenverBook
  class DenverBookForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::WorkForm
    self.model_class = ::DenverBook
    add_terms %i[title alt_title resource_type creator abstract keyword subject_text org_unit
                 date_published edition alternate_identifier library_of_congress_classification
                 related_identifier isbn publisher place_of_publication licence rights_holder rights_statement
                 contributor editor table_of_contents medium extent language time refereed add_info]
    self.terms -= %i[related_url source]
    self.required_fields = %i[title creator resource_type rights_statement]

    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior

    def primary_terms
      %i[title alt_title resource_type creator] | super
    end

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << [:edition, :contributor, :extent, :language, :add_info,
                             :alternate_identifier, :library_of_congress_classification,
                             :related_identifier, :isbn, :publisher, :place_of_publication,
                             :licence, :rights_holder, :rights_statement, :editor,
                             :table_of_contents, :medium, :time, :refereed]
      end
    end
  end
end
