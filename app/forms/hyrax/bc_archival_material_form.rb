# frozen_string_literal: true

module Hyrax
  class BcArchivalMaterialForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:bc_archival_material)

    self.model_class = ::BcArchivalMaterial
  end
end
