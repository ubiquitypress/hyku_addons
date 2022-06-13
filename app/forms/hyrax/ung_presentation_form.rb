# frozen_string_literal: true

module Hyrax
  class UngPresentationForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior
    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:ung_presentation)

    self.model_class = ::UngPresentation
  end
end
