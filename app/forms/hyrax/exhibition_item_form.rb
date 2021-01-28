# frozen_string_literal: true

module Hyrax
  class ExhibitionItemForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior
    include ::HykuAddons::WorkForm

    self.model_class = ::ExhibitionItem
    add_terms %i[title resource_type creator alt_title contributor rendering_ids abstract date_published media
                institution org_unit project_name funder fndr_project_ref event_title event_location event_date
                series_name editor version publisher place_of_publication isbn issn eissn date_accepted date_submitted
                official_link related_url related_exhibition related_exhibition_venue related_exhibition_date language
                license rights_statement rights_holder doi alternate_identifier related_identifier refereed keyword
                dewey library_of_congress_classification add_info pagination]
    self.required_fields = %i[title resource_type creator institution date_published]

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << editor_fields
        permitted_params << event_date_fields
        permitted_params << related_exhibition_date_fields
        permitted_params << additional_fields
      end
    end

    protected

    def additional_fields
      %i[series_name book_title media version isbn issn eissn pagination event_title event_location related_exhibition
        related_exhibition_venue place_of_publication]
    end
  end
end
