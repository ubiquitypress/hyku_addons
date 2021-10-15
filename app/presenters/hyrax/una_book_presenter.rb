# frozen_string_literal: true

module Hyrax
  class UnaBookPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::WorkPresenterBehavior

    def self.delegated_methods
      %i[title resource_type creator alt_email abstract
         keyword subject date_published journal_title alternative_journal_title
         journal_frequency volume issue pagination article_number version_number
         official_link alternate_identifier library_of_congress_classification
         dewey related_identifier adapted_from additional_links related_material
         related_url issn eissn publisher place_of_publication citation
         funder project_name fndr_project_ref funding_description license date_accepted
         date_submitted location longitude latitude georeferenced time
         refereed irb_number irb_status add_info].freeze
    end
    include ::HykuAddons::PresenterDelegatable
  end
end
