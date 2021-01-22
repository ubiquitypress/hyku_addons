# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificImage`
module Hyrax
  # Generated form for PacificImage
  class PacificImageForm < Hyrax::Forms::WorkForm
    # Adds behaviors for hyrax-doi plugin.
    include Hyrax::DOI::DOIFormBehavior
    # Adds behaviors for DataCite DOIs via hyrax-doi plugin.
    include Hyrax::DOI::DataCiteDOIFormBehavior
    include ::HykuAddons::WorkForm

    self.model_class = ::PacificImage
    add_terms %i[title alt_title resource_type creator contributor abstract date_published
                 is_included_in publisher additional_links
                 rights_holder license org_unit doi subject keyword add_info]

    self.required_fields = %i[title creator resource_type institution org_unit]

    def self.build_permitted_params
      super.tap do |permitted_params|
        permitted_params << common_fields
      end
    end
  end
end
