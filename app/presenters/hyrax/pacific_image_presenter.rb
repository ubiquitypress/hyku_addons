# frozen_string_literal: true

module Hyrax
  class PacificImagePresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::WorkPresenterBehavior

    def self.delegated_methods
      %i[title alt_title resource_type creator contributor abstract institution date_published
         is_included_in publisher additional_links isbn location page_display_order_number rights_holder
         license org_unit doi subject keyword add_info official_link].freeze
    end
    include ::HykuAddons::PresenterDelegatable
  end
end
