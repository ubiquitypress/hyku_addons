# frozen_string_literal: true

module Hyrax
  class DatasetForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:dataset)

    self.model_class = ::Dataset
  end
end
