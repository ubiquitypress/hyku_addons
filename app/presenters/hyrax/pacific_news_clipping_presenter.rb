# frozen_string_literal: true

module Hyrax
  class PacificNewsClippingPresenter < Hyrax::WorkShowPresenter
    include Hyrax::DOI::DOIPresenterBehavior
    include Hyrax::DOI::DataCiteDOIPresenterBehavior
    include ::HykuAddons::GenericWorkPresenterBehavior

    def self.delegated_methods
      %i[title alt_title resource_type creator contributor abstract
      date_published challenged location outcome participant reading_level
      photo_caption photo_description pagination is_included_in additional_links
      rights_holder license doi subject keyword add_info].freeze
    end
  end
end
