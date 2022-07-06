# frozen_string_literal: true

module Hyrax
  class BcImageForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:bc_image)

    self.model_class = ::BcImage
  end
end
