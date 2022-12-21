# frozen_string_literal: true

module Hyrax
  class LacArchivalMaterialForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:lac_archival_material)

    self.model_class = ::LacArchivalMaterial
  end
end
