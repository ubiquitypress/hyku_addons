# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsBook`
module Hyrax
  class RedlandsBookPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::WorkPresenterBehavior

    def self.delegated_methods
      %i[title alt_title resource_type creator alt_email abstract keyword subject
         org_unit language license version_number table_of_contents publisher place_of_publication date_published
         edition isbn official_link series_name related_identifier contributor location longitude latitude add_info].freeze
    end
    include ::HykuAddons::PresenterDelegatable
  end
end
