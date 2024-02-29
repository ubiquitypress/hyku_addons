# frozen_string_literal: true

module Hyrax
  class OkcArchivalAndLegalMaterialForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:okc_archival_and_legal_material)

    self.model_class = ::OkcArchivalAndLegalMaterial
  end
end
