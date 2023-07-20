# frozen_string_literal: true

module Hyrax
  class UngArchivalMaterialForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:ung_archival_material)

    self.model_class = ::UngArchivalMaterial
  end
end
