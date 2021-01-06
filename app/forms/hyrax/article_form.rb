# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work Article`
module Hyrax
  # Generated form for Article
  class ArticleForm < Hyrax::Forms::WorkForm
    # Adds behaviors for hyrax-doi plugin.
    include Hyrax::DOI::DOIFormBehavior
    # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
    include Hyrax::DOI::DataCiteDOIFormBehavior
    include ::HykuAddons::WorkForm

    self.model_class = ::Article
    self.terms = %i[title resource_type creator alt_title contributor rendering_ids abstract date_published
      institution org_unit project_name funder fndr_project_ref
      journal_title pagination article_num
      publisher place_of_publication issn eissn date_accepted date_submitted official_link
      related_url language license rights_statement
      rights_holder doi alternate_identifier related_identifier refereed keyword dewey
      library_of_congress_classification add_info]
    self.required_fields = %i[title resource_type creator institution]

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << creator_fields
        permitted_params << contributor_fields
        permitted_params << date_published_fields
        permitted_params << funder_fields
        permitted_params << date_accepted_fields
        permitted_params << date_submitted_fields
        permitted_params << alternate_identifier_fields
        permitted_params << related_identifier_fields
      end
    end
  end
end
