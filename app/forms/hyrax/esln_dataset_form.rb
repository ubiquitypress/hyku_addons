# frozen_string_literal: true

module Hyrax
  class EslnDatasetForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:esln_dataset)

    self.model_class = ::EslnDataset
  end
end
