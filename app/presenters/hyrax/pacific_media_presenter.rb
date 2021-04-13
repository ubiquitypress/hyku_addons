# frozen_string_literal: true

module Hyrax
  class PacificMediaPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::WorkPresenterBehavior

    def self.delegated_methods
      %i[title alt_title resource_type creator contributor institution abstract
         date_published duration version_number is_included_in page_display_order_number
         publisher additional_links rights_holder rights_holder license location
         org_unit official_link subject keyword refereed add_info].freeze
    end
    include ::HykuAddons::PresenterDelegatable
  end
end
