# frozen_string_literal: true

module Hyrax
  class ConferenceItemForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::WorkForm

    self.model_class = ::ConferenceItem
    add_terms %i[title resource_type creator alt_title contributor rendering_ids abstract date_published
                 institution org_unit project_name funder fndr_project_ref event_title event_location event_date
                 series_name book_title editor volume publisher place_of_publication isbn issn eissn date_accepted
                 date_submitted official_link related_url language license rights_statement rights_holder doi
                 alternate_identifier related_identifier refereed keyword dewey library_of_congress_classification
                 add_info pagination]
    self.required_fields = %i[title resource_type creator institution date_published]

    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior
  end
end
