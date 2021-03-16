# frozen_string_literal: true

module HykuAddons
  module GenericWorkFormOverrides
    extend ActiveSupport::Concern

    include ::HykuAddons::WorkForm

    included do
      # version is used in the show page but populated by version_number from the edit and new form
      add_terms %i[title resource_type creator alt_title contributor rendering_ids abstract date_published media
                   duration institution org_unit project_name funder fndr_project_ref event_title event_location
                   event_date series_name book_title editor journal_title alternative_journal_title volume edition
                   version_number issue pagination article_num publisher place_of_publication isbn issn eissn
                   current_he_institution date_accepted date_submitted official_link related_url related_exhibition
                   related_exhibition_venue related_exhibition_date language license rights_statement rights_holder doi
                   qualification_name qualification_level alternate_identifier related_identifier refereed keyword dewey
                   library_of_congress_classification add_info]
      self.required_fields = %i[title resource_type creator institution date_published]

      # These includes are after add_terms because they add terms
      include Hyrax::DOI::DOIFormBehavior
      include Hyrax::DOI::DataCiteDOIFormBehavior

      def primary_terms
        primary_terms = super - %i[license]

        if Flipflop.enabled?(:simplified_admin_set_selection)
          primary_terms + %i[admin_set_id member_of_collection_id]
        else
          primary_terms
        end
      end
    end
  end
end
