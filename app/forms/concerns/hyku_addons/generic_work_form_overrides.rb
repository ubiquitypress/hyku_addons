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
      self.required_fields = %i[title resource_type creator institution]

      # Adds behaviors for hyrax-doi plugin.
      include Hyrax::DOI::DOIFormBehavior
      # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
      include Hyrax::DOI::DataCiteDOIFormBehavior

      def primary_terms
        super - %i[license]
      end
    end

    class_methods do
      def build_permitted_params
        super.tap do |permitted_params|
          permitted_params << common_fields
          permitted_params << editor_fields
          permitted_params << event_date_fields
          permitted_params << editor_fields
          permitted_params << current_he_institution_fields
          permitted_params << date_accepted_fields
          permitted_params << date_submitted_fields
          permitted_params << related_exhibition_date_fields
          permitted_params << alternate_identifier_fields
          permitted_params << related_identifier_fields
        end
      end
    end

    def editor_list
      person_or_organization_list(:editor)
    end
  end
end
