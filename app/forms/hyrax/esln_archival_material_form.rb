# frozen_string_literal: true

module Hyrax
  class EslnArchivalMaterialForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:esln_archival_material)

    self.model_class = ::EslnArchivalMaterial
  end
end
