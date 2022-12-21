# frozen_string_literal: true

module Hyrax
  class LacImageForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:lac_image)

    self.model_class = ::LacImage
  end
end
