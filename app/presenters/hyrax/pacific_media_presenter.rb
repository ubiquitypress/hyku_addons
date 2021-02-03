# Generated via
#  `rails generate hyrax:work PacificMedia`
module Hyrax
  class PacificMediaPresenter < Hyrax::WorkShowPresenter
    # Adds behaviors for hyrax-doi plugin.
    include Hyrax::DOI::DOIPresenterBehavior
    # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
    include Hyrax::DOI::DataCiteDOIPresenterBehavior
    include ::HykuAddons::GenericWorkPresenterBehavior

    DELEGATED_METHODS = %i[title alt_title resource_type creator contributor institution abstract
                           date_published duration version is_included_in
                           publisher additional_links rights_holder license
                           org_unit doi subject keyword refereed add_info].freeze
  end
end
