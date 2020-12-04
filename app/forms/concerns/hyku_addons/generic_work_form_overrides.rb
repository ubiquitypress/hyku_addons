# frozen_string_literal: true
module HykuAddons
  module GenericWorkFormOverrides
    extend ActiveSupport::Concern

    included do
      # version is used in the show page but populated by version_number from the edit and new form
      self.terms = %i[title alt_title resource_type creator contributor rendering_ids abstract date_published media duration
                      institution org_unit project_name funder fndr_project_ref event_title event_location event_date
                      series_name book_title editor journal_title alternative_journal_title volume edition version_number issue pagination article_num
                      publisher place_of_publication isbn issn eissn current_he_institution date_accepted date_submitted official_link
                      related_url related_exhibition related_exhibition_venue related_exhibition_date language license rights_statement
                      rights_holder doi qualification_name qualification_level alternate_identifier related_identifier refereed keyword dewey
                      library_of_congress_classification add_info rendering_ids]
      self.required_fields = %i[title creator resource_type institution]
    end
  end
end
