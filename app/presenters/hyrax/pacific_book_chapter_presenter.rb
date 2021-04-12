# frozen_string_literal: true

module Hyrax
  class PacificBookChapterPresenter < Hyrax::WorkShowPresenter
    include Hyrax::DOI::DOIPresenterBehavior
    include Hyrax::DOI::DataCiteDOIPresenterBehavior
    include ::HykuAddons::WorkPresenterBehavior

    def self.delegated_methods
      %i[title alt_title resource_type creator institution contributor abstract page_display_order_number official_link
         date_published book_title pagination is_included_in volume publisher isbn issn additional_links rights_holder
         license location org_unit doi subject keyword refereed add_info].freeze
    end
    include ::HykuAddons::PresenterDelegatable
  end
end
