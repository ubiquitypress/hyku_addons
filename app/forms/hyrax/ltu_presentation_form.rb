# frozen_string_literal: true

module Hyrax
  class LtuPresentationForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior
    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:ltu_presentation)

    self.model_class = ::LtuPresentation
  end
end
