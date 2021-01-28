# frozen_string_literal: true

module Hyrax
  class PacificImageForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior
    include ::HykuAddons::WorkForm

    self.model_class = ::PacificImage
    add_terms %i[title alt_title resource_type creator contributor abstract date_published
                 is_included_in publisher additional_links
                 rights_holder license org_unit doi subject keyword add_info]

    self.required_fields = %i[title creator resource_type institution org_unit]
  end
end
