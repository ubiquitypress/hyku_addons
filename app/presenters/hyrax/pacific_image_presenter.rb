# frozen_string_literal: true

module Hyrax
  class PacificImagePresenter < Hyrax::WorkShowPresenter
    include Hyrax::DOI::DOIPresenterBehavior
    include Hyrax::DOI::DataCiteDOIPresenterBehavior
    include ::HykuAddons::GenericWorkPresenterBehavior

    def self.delegated_methods
      %i[title alt_title resource_type creator contributor abstract institution date_published
         is_included_in publisher additional_links rights_holder license org_unit doi subject keyword add_info].freeze
    end
  end
end
