# frozen_string_literal: true

module Hyrax
  class ArchivalMaterialForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:archival_material)

    self.model_class = ::ArchivalMaterial
  end
end
