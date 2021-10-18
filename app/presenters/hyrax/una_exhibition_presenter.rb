# frozen_string_literal: true

module Hyrax
  class UnaExhibitionPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::WorkPresenterBehavior

    def self.delegated_methods
      %i[title alt_title resource_type creator current_he_institution
         alt_email abstract keyword subject subject_text official_link
         alternate_identifier citation funder project_name fndr_project_ref
         event_title event_location event_date related_exhibition related_exhibition_date
         license rights_holder rights_statement rights_statement_text contributor
         medium extent duration is_format_of language location longitude
         latitude georeferenced time refereed irb_number irb_status add_info].freeze
    end
    include ::HykuAddons::PresenterDelegatable
  end
end
