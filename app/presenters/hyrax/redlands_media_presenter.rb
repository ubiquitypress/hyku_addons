# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsMedia`
module Hyrax
  class RedlandsMediaPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::WorkPresenterBehavior

    def self.delegated_methods
      %i[title alt_title resource_type creator alt_email abstract keyword subject
         org_unit language license date_published event_location official_link contributor location
         longitude latitude add_info].freeze
    end
    include ::HykuAddons::PresenterDelegatable
  end
end
