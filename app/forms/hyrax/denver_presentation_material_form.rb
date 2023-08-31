# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverPresentationMaterial`
module Hyrax
  # Generated form for DenverPresentationMaterial
  class DenverPresentationMaterialForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:denver_presentation_material)

    self.model_class = ::DenverPresentationMaterial
  end
end
