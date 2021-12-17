# frozen_string_literal: true

module Hyrax
  class ThesisOrDissertationForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::WorkForm

    self.model_class = ::ThesisOrDissertation
    add_terms %i[title resource_type creator alt_title contributor rendering_ids abstract date_published
                 institution org_unit project_name funder fndr_project_ref version_number publisher
                 current_he_institution date_accepted date_submitted official_link related_url language
                 license rights_statement rights_holder doi qualification_name qualification_level alternate_identifier
                 related_identifier refereed keyword dewey library_of_congress_classification add_info pagination]

    self.required_fields = %i[title resource_type creator date_published institution qualification_level
                              qualification_name]

    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior
  end
end
