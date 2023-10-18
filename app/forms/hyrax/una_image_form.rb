# frozen_string_literal: true
module Hyrax
  class UnaImageForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:una_image)

    self.model_class = ::UnaImage
  end
end
