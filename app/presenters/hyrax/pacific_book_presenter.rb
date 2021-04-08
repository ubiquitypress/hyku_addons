# frozen_string_literal: true

module Hyrax
  class PacificBookPresenter < Hyrax::WorkShowPresenter
    include Hyrax::DOI::DOIPresenterBehavior
    include Hyrax::DOI::DataCiteDOIPresenterBehavior
    include ::HykuAddons::GenericWorkPresenterBehavior

    def self.delegated_methods
      %i[title alt_title resource_type creator contributor abstract institution date_published
         pagination is_included_in volume buy_book publisher isbn issn additional_links
         rights_holder license org_unit doi subject keyword refereed add_info].freeze
    end
  end
end
