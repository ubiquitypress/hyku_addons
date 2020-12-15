# frozen_string_literal: true
module HykuAddons
  module GenericWorkFormOverrides
    extend ActiveSupport::Concern

    included do
      # version is used in the show page but populated by version_number from the edit and new form
      self.terms = %i[title resource_type creator alt_title contributor rendering_ids abstract date_published media duration
                      institution org_unit project_name funder fndr_project_ref event_title event_location event_date
                      series_name book_title editor journal_title alternative_journal_title volume edition version_number issue pagination article_num
                      publisher place_of_publication isbn issn eissn current_he_institution date_accepted date_submitted official_link
                      related_url related_exhibition related_exhibition_venue related_exhibition_date language license rights_statement
                      rights_holder doi qualification_name qualification_level alternate_identifier related_identifier refereed keyword dewey
                      library_of_congress_classification add_info]
      self.required_fields = %i[title resource_type creator institution]
    end

    class_methods do
      def build_permitted_params
        super.tap do |permitted_params|
          permitted_params << { creator: [:creator_organization_name, :creator_given_name,
            :creator_family_name, :creator_name_type, :creator_orcid, :creator_isni,  :creator_ror, :creator_grid,
            :creator_wikidata, :creator_position, :creator_institutional_relationship => []
          ]}
          permitted_params << {contributor: [:contributor_organization_name, :contributor_given_name,
            :contributor_family_name, :contributor_name_type, :contributor_orcid, :contributor_isni, :contributor_ror, :contributor_grid,
            :contributor_wikidata, :contributor_position, :contributor_type, :contributor_institutional_relationship => []
          ]}
          permitted_params << { date_published: [:date_published_year, :date_published_month, :date_published_day] }
          permitted_params << { funder: [:funder_name, :funder_doi, :funder_position, :funder_isni, :funder_ror, :funder_award => []] }
          permitted_params << { event_date: [:event_date_year, :event_date_month, :event_date_day] }
          permitted_params << { editor: [:editor_given_name,
            :editor_family_name, :editor_name_type, :editor_orcid, :editor_isni,
            :editor_position, :editor_organization_name, :editor_institutional_relationship => []
          ]}
          permitted_params << { current_he_institution: [:current_he_institution_name, :current_he_institution_isni, :current_he_institution_ror] }
          permitted_params << { date_accepted: [:date_accepted_year, :date_accepted_month, :date_accepted_day] }
          permitted_params << { date_submitted: [:date_submitted_year, :date_submitted_month, :date_submitted_day] }
          permitted_params << { related_exhibition_date: [:related_exhibition_date_year, :related_exhibition_date_month, :related_exhibition_date_day] }
          permitted_params << { alternate_identifier: [:alternate_identifier, :alternate_identifier_type] }
          permitted_params << { related_identifier: [:related_identifier, :related_identifier_type, :relation_type] }
        end
      end
    end
  end
end
