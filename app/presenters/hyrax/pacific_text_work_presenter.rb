# frozen_string_literal: true

module Hyrax
  class PacificTextWorkPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::WorkPresenterBehavior

    def self.delegated_methods
      %i[title alt_title resource_type creator contributor abstract page_display_order_number official_link
         date_published pagination is_included_in volume publisher issn source additional_links rights_holder license
         location org_unit doi subject keyword refereed add_info].freeze
    end
    include ::HykuAddons::PresenterDelegatable
  end
end
