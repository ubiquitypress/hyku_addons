module Hyrax
  class TimeBasedMediaArticleForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior
    include ::HykuAddons::GenericWorkFormOverrides

    self.model_class = ::TimeBasedMediaArticle
    self.terms = %i[title resource_type abstract add_info alt_title alternate_identifier
                    alternative_journal_title contributor creator date_accepted date_published date_submitted dewey doi
                    fndr_project_ref funder institution issue keyword language library_of_congress_classification
                    license official_link org_unit place_of_publication project_name publisher related_identifier
                    related_url rights_holder rights_statement]
    self.required_fields = %i[title resource_type creator institution]

		def build_permitted_params
      raise super.inspect
			super.tap do |permitted_params|
				permitted_params << { creator: [:creator_organization_name, :creator_given_name,
																:creator_family_name, :creator_name_type, :creator_orcid, :creator_isni, :creator_ror,
																:creator_grid, :creator_wikidata, creator_institutional_relationship: []] }
				permitted_params << { contributor: [:contributor_organization_name, :contributor_given_name,
																						:contributor_family_name, :contributor_name_type, :contributor_orcid,
																						:contributor_isni, :contributor_ror, :contributor_grid,
																						:contributor_wikidata, :contributor_type,
																						contributor_institutional_relationship: []] }
				permitted_params << { date_published: [:date_published_year, :date_published_month, :date_published_day] }
				permitted_params << { funder: [:funder_name, :funder_doi, :funder_isni, :funder_ror, funder_award: []] }
				permitted_params << { date_accepted: [:date_accepted_year, :date_accepted_month, :date_accepted_day] }
				permitted_params << { date_submitted: [:date_submitted_year, :date_submitted_month, :date_submitted_day] }
				permitted_params << { alternate_identifier: [:alternate_identifier, :alternate_identifier_type] }
				permitted_params << { related_identifier: [:related_identifier, :related_identifier_type, :relation_type] }
			end
    end
  end
end
