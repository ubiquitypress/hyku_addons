# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificNewsClipping`
module Hyrax
  class PacificNewsClippingPresenter < Hyrax::WorkShowPresenter
    # Adds behaviors for hyrax-doi plugin.
    include Hyrax::DOI::DOIPresenterBehavior
    # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
    include Hyrax::DOI::DataCiteDOIPresenterBehavior
    include ::HykuAddons::GenericWorkPresenterBehavior

    DELEGATED_METHODS = %i[title alt_title resource_type creator creator_json contributor abstract
                           date_published challenged location outcome participant reading_level
                           photo_caption photo_description pagination is_included_in additional_links
                           rights_holder license doi subject keyword add_info].freeze
  end
end
