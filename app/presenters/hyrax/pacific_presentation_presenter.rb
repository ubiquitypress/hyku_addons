# frozen_string_literal: true

module Hyrax
  class PacificPresentationPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::WorkPresenterBehavior

    def self.delegated_methods
      %i[title alt_title resource_type creator contributor abstract page_display_order_number official_link
         date_published pagination is_included_in volume publisher issn additional_links rights_holder license
         org_unit doi subject keyword refereed add_info location].freeze
    end
    include ::HykuAddons::PresenterDelegatable
  end
end
