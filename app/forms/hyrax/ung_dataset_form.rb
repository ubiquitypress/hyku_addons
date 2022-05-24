# frozen_string_literal: true

module Hyrax
  class UngDatasetForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:ung_dataset)

    self.model_class = ::UngDataset
  end
end
