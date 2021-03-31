# Generated via
#  `rails generate hyrax:work UvaWork`
module Hyrax
  class UvaWorkPresenter < Hyrax::WorkShowPresenter
    # Adds behaviors for hyrax-doi plugin.
    include Hyrax::DOI::DOIPresenterBehavior
    # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
    include Hyrax::DOI::DataCiteDOIPresenterBehavior
    include ::HykuAddons::GenericWorkPresenterBehavior

    DELEGATED_METHODS = %i[title resource_type creator abstract license keyword contributor language
                           publisher date_published related_url funder add_info].freeze
  end
end
