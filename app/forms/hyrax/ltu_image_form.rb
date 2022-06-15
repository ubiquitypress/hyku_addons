# frozen_string_literal: true

module Hyrax
  class LtuImageForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:ltu_image)

    self.model_class = ::LtuImage
  end
end
