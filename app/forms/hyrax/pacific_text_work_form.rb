# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificTextWork`
module Hyrax
  # Generated form for PacificTextWork
  class PacificTextWorkForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:pacific_text_work)

    self.model_class = ::PacificTextWork
  end
end
