# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverImage`
module Hyrax
  class DenverImagePresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::WorkPresenterBehavior

    def self.delegated_methods
      %i[title alt_title resource_type creator abstract keyword subject org_unit
         date_published alternate_identifier related_identifier related_exhibition
         related_exhibition_venue related_exhibition_date licence rights_holder
         rights_statement contributor extent language location longditude latitude
         georeferenced add_info].freeze
    end
    include ::HykuAddons::PresenterDelegatable
  end
end
