# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work ExhibitionItem`
module Hyrax
  # Generated form for ExhibitionItem
  class ExhibitionItemForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DOIFormBehavior
    # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
    include Hyrax::DOI::DataCiteDOIFormBehavior
    include ::HykuAddons::WorkForm
    self.model_class = ::ExhibitionItem
    add_terms %i[title resource_type creator alt_title contributor rendering_ids abstract date_published event_title event_location event_date
                 institution org_unit project_name funder fndr_project_ref series_name editor media version
                 publisher place_of_publication isbn issn eissn date_accepted date_submitted official_link related_url
                 language license rights_statement rights_holder doi alternate_identifier related_identifier refereed
                 keyword dewey library_of_congress_classification add_info pagination related_exhibition related_exhibition_venue
                 related_exhibition_date]
    self.required_fields = %i[title resource_type creator institution]

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
        permitted_params << editor_fields
        permitted_params << event_date_fields
        permitted_params << related_exhibition_date_fields
        permitted_params << %i[series_name book_title media version isbn issn eissn pagination event_title event_location
                               related_exhibition related_exhibition_venue place_of_publication]
      end
    end

    def editor_list
      person_or_organization_list(:editor)
    end
  end
end
