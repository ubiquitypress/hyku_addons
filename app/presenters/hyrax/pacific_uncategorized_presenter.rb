# frozen_string_literal: true

module Hyrax
  class PacificUncategorizedPresenter < Hyrax::WorkShowPresenter
    include Hyrax::DOI::DOIPresenterBehavior
    include Hyrax::DOI::DataCiteDOIPresenterBehavior
    include ::HykuAddons::WorkPresenterBehavior

    def self.delegated_methods
      %i[title alt_title resource_type creator contributor abstract page_display_order_number official_link
         date_published duration version pagination is_included_in volume_number issue journal_title publisher isbn
         issn additional_links rights_holder license location doi degree org_unit subject keyword refereed irb_status
         irb_number add_info].freeze
    end
    include ::HykuAddons::PresenterDelegatable
  end
end
