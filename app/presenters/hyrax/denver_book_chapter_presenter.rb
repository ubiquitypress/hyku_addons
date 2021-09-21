# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverBookChapter`
module Hyrax
  class DenverBookChapterPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::WorkPresenterBehavior

    def self.delegated_methods
      %i[title alt_title resource_type creator institution abstract keyword
         subject_text org_unit date_published buy_book alt_book_title edition
         pagination alternate_identifier library_of_congress_classification
         related_identifier isbn publisher place_of_publication license
         rights_holder rights_statement contributor editor medium language time refereed add_info].freeze
    end
    include ::HykuAddons::PresenterDelegatable
  end
end
