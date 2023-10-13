# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificUncategorized`
module Hyrax
  # Generated form for PacificUncategorized
  class PacificUncategorizedForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:pacific_uncategorized)

    self.model_class = ::PacificUncategorized
  end
end
