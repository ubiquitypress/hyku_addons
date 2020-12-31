# Generated via
#  `rails generate hyrax:work BookContribution`
module Hyrax
  # Generated form for BookContribution
  class BookContributionForm < Hyrax::Forms::WorkForm
    # Adds behaviors for hyrax-doi plugin.
    include Hyrax::DOI::DOIFormBehavior
    # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
    include Hyrax::DOI::DataCiteDOIFormBehavior
    include ::HykuAddons::GenericWorkFormOverrides

    self.model_class = ::BookContribution
    self.terms -= %i[media duration event_title event_location event_date series_name edition version_number
                     current_he_institution related_exhibition related_exhibition_venue related_exhibition_date
                     qualification_name qualification_level journal_title issue article_number]

    def build_permitted_params
      super.tap do |permitted_params|
        permitted_params << { creator: [:creator_organization_name, :creator_given_name,
                                        :creator_family_name, :creator_name_type, :creator_orcid, :creator_isni, :creator_ror, :creator_grid,
                                        :creator_wikidata, creator_institutional_relationship: []] }
        permitted_params << { contributor: [:contributor_organization_name, :contributor_given_name,
                                            :contributor_family_name, :contributor_name_type, :contributor_orcid, :contributor_isni, :contributor_ror, :contributor_grid,
                                            :contributor_wikidata, :contributor_type, contributor_institutional_relationship: []] }
        permitted_params << { date_published: [:date_published_year, :date_published_month, :date_published_day] }
        permitted_params << { editor: [:editor_isni, :editor_orcid, :editor_family_name, :editor_given_name, :editor_organisational_name, :editor_institutional_relationship] }
        permitted_params << { funder: [:funder_name, :funder_doi, :funder_isni, :funder_ror, funder_award: []] }
        permitted_params << { date_accepted: [:date_accepted_year, :date_accepted_month, :date_accepted_day] }
        permitted_params << { date_submitted: [:date_submitted_year, :date_submitted_month, :date_submitted_day] }
        permitted_params << { alternate_identifier: [:alternate_identifier, :alternate_identifier_type] }
        permitted_params << { related_identifier: [:related_identifier, :related_identifier_type, :relation_type] }
      end
    end

    # Helper methods for JSON fields
    def creator_list
      person_or_organization_list(:creator)
    end

    def contributor_list
      person_or_organization_list(:contributor)
    end

    private

    def person_or_organization_list(field)
      # Return empty hash to ensure that it gets rendered at least once
      return [{}] unless send(field)&.first.present?
      JSON.parse(send(field).first)
    end
  end
end
