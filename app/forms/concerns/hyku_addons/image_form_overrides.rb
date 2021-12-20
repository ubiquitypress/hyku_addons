# frozen_string_literal: true

module HykuAddons
  module ImageFormOverrides
    extend ActiveSupport::Concern

    include ::HykuAddons::WorkForm

    included do
      add_terms %i[title resource_type creator alt_title contributor rendering_ids abstract date_published media
                   duration institution org_unit project_name funder fndr_project_ref
                   publisher place_of_publication date_accepted date_submitted official_link related_url
                   related_exhibition related_exhibition_venue related_exhibition_date language license rights_statement
                   rights_holder doi alternate_identifier related_identifier refereed keyword dewey
                   library_of_congress_classification add_info]
      self.required_fields = %i[title resource_type creator institution date_published]

      # These must be added after the terms are defined
      include Hyrax::DOI::DOIFormBehavior
      include Hyrax::DOI::DataCiteDOIFormBehavior
    end
  end
end
