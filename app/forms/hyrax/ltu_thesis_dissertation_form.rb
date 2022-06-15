# frozen_string_literal: true

module Hyrax
  class LtuThesisDissertationForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:ltu_thesis_dissertation)

    self.model_class = ::LtuThesisDissertation
  end
end
