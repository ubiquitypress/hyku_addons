# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificImage`
module Hyrax
  class PacificImagePresenter < Hyrax::WorkShowPresenter
    # Adds behaviors for hyrax-doi plugin.
    include Hyrax::DOI::DOIPresenterBehavior
    # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
    include Hyrax::DOI::DataCiteDOIPresenterBehavior
    include ::HykuAddons::GenericWorkPresenterBehavior

    DELEGATED_METHODS = %i[title alt_title resource_type creator contributor abstract institution date_published
                           is_included_in publisher additional_links isbn location page_display_order_number
                           rights_holder license org_unit doi subject keyword add_info].freeze
  end
end
