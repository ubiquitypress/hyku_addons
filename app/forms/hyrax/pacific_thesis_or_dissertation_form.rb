# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificThesisOrDissertation`
module Hyrax
  # Generated form for PacificThesisOrDissertation
  class PacificThesisOrDissertationForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:pacific_thesis_or_dissertation)

    self.model_class = ::PacificThesisOrDissertation
  end
end
