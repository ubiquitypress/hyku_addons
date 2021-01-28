# frozen_string_literal: true

module Hyrax
  class ThesisOrDisertationForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior
    include ::HykuAddons::WorkForm

    self.model_class = ::ThesisOrDisertation
    add_terms %i[title resource_type creator alt_title contributor rendering_ids abstract date_published
                 institution org_unit project_name funder fndr_project_ref publisher current_he_institution
                 date_accepted date_submitted official_link related_url language license rights_statement rights_holder
                 doi qualification_name qualification_level alternate_identifier related_identifier refereed keyword
                 dewey library_of_congress_classification add_info pagination]

    self.required_fields = %i[title resource_type creator date_published institution qualification_level
                              qualification_name]

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << current_he_institution_fields
        permitted_params << alternate_identifier_fields
        permitted_params << related_identifier_fields
        permitted_params << %i[org_unit publisher place_of_publication qualification_name qualification_level]
      end
    end
  end
end
