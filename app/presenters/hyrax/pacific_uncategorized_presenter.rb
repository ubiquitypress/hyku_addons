# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificUncategorized`
module Hyrax
  class PacificUncategorizedPresenter < Hyrax::WorkShowPresenter
    # Adds behaviors for hyrax-doi plugin.
    include Hyrax::DOI::DOIPresenterBehavior
    # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
    include Hyrax::DOI::DataCiteDOIPresenterBehavior
    include ::HykuAddons::GenericWorkPresenterBehavior

    DELEGATED_METHODS = %i[title alt_title resource_type creator contributor abstract page_display_order_number official_link
                           date_published duration version pagination is_included_in volume_number issue journal_title publisher isbn issn additional_links rights_holder license
                           location doi degree org_unit subject keyword refereed irb_status irb_number add_info].freeze
  end
end
