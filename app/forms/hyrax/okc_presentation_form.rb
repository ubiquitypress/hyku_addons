# frozen_string_literal: true

module Hyrax
  class OkcPresentationForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:okc_presentation)

    self.model_class = ::OkcPresentation
  end
end
