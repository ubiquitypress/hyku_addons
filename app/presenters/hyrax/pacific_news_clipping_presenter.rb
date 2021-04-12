# frozen_string_literal: true

module Hyrax
  class PacificNewsClippingPresenter < Hyrax::WorkShowPresenter
    include Hyrax::DOI::DOIPresenterBehavior
    include Hyrax::DOI::DataCiteDOIPresenterBehavior
    include ::HykuAddons::WorkPresenterBehavior

    def self.delegated_methods
      %i[title alt_title resource_type creator contributor abstract official_link
         date_published challenged location outcome participant reading_level
         photo_caption photo_description pagination is_included_in additional_links
         page_display_order_number rights_holder license doi subject keyword add_info].freeze
    end
    include ::HykuAddons::PresenterDelegatable
  end
end
