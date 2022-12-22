# frozen_string_literal: true

module Hyrax
  class LacThesisDissertationForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:lac_thesis_dissertation)

    self.model_class = ::LacThesisDissertation
  end
end
