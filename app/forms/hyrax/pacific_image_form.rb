# frozen_string_literal: true

module Hyrax
  class PacificImageForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:pacific_image)

    self.model_class = ::PacificImage
  end
end
