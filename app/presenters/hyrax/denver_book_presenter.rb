# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverBook`
module Hyrax
  class DenverBookPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::WorkPresenterBehavior

    def self.delegated_methods
      %i[title alt_title resource_type creator abstract keyword subject_text org_unit
         date_published edition alternate_identifier library_of_congress_classification
         related_identifier isbn publisher place_of_publication licence rights_holder rights_statement
         contributor editor table_of_contents medium extent language time refereed add_info].freeze
    end
    include ::HykuAddons::PresenterDelegatable
  end
end
