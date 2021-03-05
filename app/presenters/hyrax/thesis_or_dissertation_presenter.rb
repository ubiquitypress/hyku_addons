# frozen_string_literal: true
module Hyrax
  class ThesisOrDissertationPresenter < Hyrax::WorkShowPresenter
    include Hyrax::DOI::DOIPresenterBehavior
    include Hyrax::DOI::DataCiteDOIPresenterBehavior
    include ::HykuAddons::GenericWorkPresenterBehavior

    DELEGATED_METHODS = %i[title resource_type creator creator_json alt_title contributor_display rendering_ids abstract
                           date_published institution org_unit project_name funder fndr_project_ref version_number publisher
                           current_he_institution date_accepted date_submitted official_link related_url language license
                           rights_statement rights_holder doi qualification_name qualification_level alternate_identifier
                           related_identifier refereed keyword dewey library_of_congress_classification add_info
                           pagination].freeze
  end
end
