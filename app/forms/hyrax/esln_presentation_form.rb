# frozen_string_literal: true

module Hyrax
  class EslnPresentationForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior
    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:esln_presentation)

    self.model_class = ::EslnPresentation
  end
end
