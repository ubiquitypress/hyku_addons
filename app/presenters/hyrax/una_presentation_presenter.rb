# frozen_string_literal: true

module Hyrax
  class UnaPresentationPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::WorkPresenterBehavior

    def self.delegated_methods
      %i[title alt_title resource_type creator alt_email abstract keyword
         subject org_unit language license publisher date_published event_location
         official_link contributor location longitude latitude add_info
         event_title event_location event_date].freeze
    end
    include ::HykuAddons::PresenterDelegatable
  end
end
