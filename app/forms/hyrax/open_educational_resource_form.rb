# frozen_string_literal: true

module Hyrax
  class OpenEducationalResourceForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:open_educational_resource)

    self.model_class = ::OpenEducationalResource
  end
end