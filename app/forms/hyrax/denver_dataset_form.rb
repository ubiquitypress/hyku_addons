# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverDataset`
module Hyrax
  # Generated form for DenverDataset
  class DenverDatasetForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:denver_dataset)

    self.model_class = ::DenverDataset
  end
end
