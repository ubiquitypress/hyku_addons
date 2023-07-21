# frozen_string_literal: true

module Hyrax
  class UngImageForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:ung_image)

    self.model_class = ::UngImage
  end
end
