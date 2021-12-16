# frozen_string_literal: true

module Hyrax
  class TimeBasedMediaForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::WorkForm

    self.model_class = ::TimeBasedMedia
    add_terms %i[title resource_type creator alt_title contributor rendering_ids abstract date_published media
                 duration institution org_unit project_name funder fndr_project_ref event_title event_location event_date
                 editor publisher place_of_publication date_accepted date_submitted
                 official_link related_url related_exhibition related_exhibition_venue related_exhibition_date language
                 license rights_statement rights_holder doi alternate_identifier related_identifier refereed keyword
                 dewey library_of_congress_classification add_info]
    self.required_fields = %i[title resource_type creator institution date_published]

    include HykuAddons::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior
  end
end
