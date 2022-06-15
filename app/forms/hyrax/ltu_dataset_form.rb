# frozen_string_literal: true

module Hyrax
  class LtuDatasetForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:ltu_dataset)

    self.model_class = ::LtuDataset
  end
end
