# frozen_string_literal: true

module Hyrax
  class PacificMediaPresenter < Hyrax::WorkShowPresenter
    include Hyrax::DOI::DOIPresenterBehavior
    include Hyrax::DOI::DataCiteDOIPresenterBehavior
    include ::HykuAddons::GenericWorkPresenterBehavior

    def self.delegated_methods
      %i[title alt_title resource_type creator contributor institution abstract
         date_published duration version_number is_included_in
         publisher additional_links rights_holder license
         org_unit official_link subject keyword refereed add_info].freeze
    end
  end
end
