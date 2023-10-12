# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificPresentation`
module Hyrax
  # Generated form for PacificPresentation
  class PacificPresentationForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:pacific_presentation)

    self.model_class = ::PacificPresentation
  end
end
