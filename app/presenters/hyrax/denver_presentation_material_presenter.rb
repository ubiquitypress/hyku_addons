# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverPresentationMaterial`
module Hyrax
  class DenverPresentationMaterialPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::WorkPresenterBehavior

    def self.delegated_methods
      %i[title resource_type creator abstract keyword subject org_unit
         date_published related_identifier event_title event_location event_date
         licence rights_holder rights_statement contributor language add_info].freeze
    end
    include ::HykuAddons::PresenterDelegatable
  end
end
