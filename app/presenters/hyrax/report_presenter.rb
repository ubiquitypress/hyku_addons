# frozen_string_literal: true

module Hyrax
  class ReportPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::WorkPresenterBehavior

    def self.delegated_methods
      %i[title resource_type creator_display alt_title contributor_display rendering_ids abstract
         date_published institution org_unit project_name funder fndr_project_ref series_name
         editor editor_display volume edition publisher place_of_publication isbn issn eissn date_accepted
         date_submitted official_link related_url language license rights_statement rights_holder doi
         alternate_identifier related_identifier refereed keyword dewey
         library_of_congress_classification add_info pagination date_created description].freeze
    end
    include ::HykuAddons::PresenterDelegatable

    # Must be included after delegated_methods
    include ::HykuAddons::EditorListable
  end
end
