# frozen_string_literal: true

module Hyrax
  class PacificBookPresenter < Hyrax::WorkShowPresenter

    def self.delegated_methods
      %i[title alt_title resource_type creator contributor abstract institution date_published official_link
         pagination is_included_in volume buy_book publisher isbn issn additional_links page_display_order_number
         location rights_holder license org_unit doi subject keyword refereed add_info].freeze
    end
    include ::HykuAddons::PresenterDelegatable
  end
end
