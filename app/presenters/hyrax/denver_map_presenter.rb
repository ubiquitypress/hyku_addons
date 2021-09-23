# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverMap`
module Hyrax
  class DenverMapPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::WorkPresenterBehavior

    def self.delegated_methods
      %i[title alt_title resource_type creator abstract keyword subject org_unit
         date_published alternate_identifier related_identifier related_exhibition
         related_exhibition_venue related_exhibition_date license rights_holder
         rights_statement contributor extent language location longitude latitude
         georeferenced add_info].freeze
    end
    include ::HykuAddons::PresenterDelegatable
  end
end
