# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsChaptersAndBookSection`
module Hyrax
  class RedlandsChaptersAndBookSectionPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::WorkPresenterBehavior

    def self.delegated_methods
      %i[title alt_title resource_type creator contributor alt_email abstract keyword subject
         org_unit language license version_number publisher place_of_publication date_published book_title
         alt_book_title edition pagination isbn official_link series_name related_identifier location
         longitude latitude add_info buy_book].freeze
    end
    include ::HykuAddons::PresenterDelegatable
  end
end
