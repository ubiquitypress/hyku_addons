# frozen_string_literal: true
module Hyrax
  class UnaImagePresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::WorkPresenterBehavior

    def self.delegated_methods
      %i[title alt_title resource_type creator alt_email abstract keyword
         subject subject_text date_published date_published_text official_link
         alternate_identifier library_of_congress_classification related_identifier
         event_title event_location event_date related_exhibition related_exhibition_venue
         related_exhibition_date license rights_holder rights_statement
         rights_statement_text contributor medium extent duration is_format_of
         language location longitude latitude georeferenced time add_info].freeze
    end
    include ::HykuAddons::PresenterDelegatable
  end
end
