# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverMultimedia`
module Hyrax
  class DenverMultimediaPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::WorkPresenterBehavior

    def self.delegated_methods
      %i[title alt_title resource_type creator abstract keyword subject
         date_published alternate_identifier library_of_congress_classification
         related_identifier publisher place_of_publication event_title event_location
         license rights_holder rights_statement contributor medium duration
         language add_info].freeze
    end
    include ::HykuAddons::PresenterDelegatable
  end
end
