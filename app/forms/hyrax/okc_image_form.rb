# frozen_string_literal: true

module Hyrax
  class OkcImageForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:okc_image)

    self.model_class = ::OkcImage
  end
end
