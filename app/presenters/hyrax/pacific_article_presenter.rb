# frozen_string_literal: true

module Hyrax
  class PacificArticlePresenter < Hyrax::WorkShowPresenter
    include Hyrax::DOI::DOIPresenterBehavior
    include Hyrax::DOI::DataCiteDOIPresenterBehavior
    include ::HykuAddons::WorkPresenterBehavior

    def self.delegated_methods
      %i[title alt_title resource_type creator contributor abstract institution date_published pagination
         issue page_display_order_number volume journal_title publisher issn source additional_links
         isbn buy_book location official_link rights_holder license org_unit doi subject keyword refereed irb_status
         irb_number add_info].freeze
    end
  end
end
