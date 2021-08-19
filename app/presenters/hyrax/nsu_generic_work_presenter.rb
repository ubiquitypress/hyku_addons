# frozen_string_literal: true

module Hyrax
  class NsuGenericWorkPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::WorkPresenterBehavior

    def self.delegated_methods
      %i[title alt_title resource_type creator alt_email abstract
         keyword subject degree qualification_level qualification_name
         advisor org_unit date_published book_title alt_book_title
         buy_book edition volume issue pagination version_number official_link
         library_of_congress_classification dewey mesh related_identifier adapted_from
         series_name source isbn issn eissn publisher place_of_publication funder
         event_title event_location event_date related_exhibition related_exhibition_venue
         related_exhibition_date license rights_holder rights_statement contributor
         editor date_accepted date_submitted table_of_contents references medium extent duration
         language audience prerequisites location longitude latitude time refereed
         suggested_reviewers suggested_student_reviewers irb_number irb_status add_info].freeze
    end
    include ::HykuAddons::PresenterDelegatable
  end
end
