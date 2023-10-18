# frozen_string_literal: true
module Hyrax
  class UnaPresentationForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:una_presentation)

    self.model_class = ::UnaPresentation
  end
end
