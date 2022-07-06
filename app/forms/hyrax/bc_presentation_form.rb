# frozen_string_literal: true

module Hyrax
  class BcPresentationForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:bc_presentation)

    self.model_class = ::BcPresentation
  end
end
