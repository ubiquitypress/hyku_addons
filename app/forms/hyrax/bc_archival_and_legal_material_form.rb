# frozen_string_literal: true

module Hyrax
  class BcArchivalAndLegalMaterialForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:bc_archival_and_legal_material)

    self.model_class = ::BcArchivalAndLegalMaterial
  end
end
