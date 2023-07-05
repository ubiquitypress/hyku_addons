# frozen_string_literal: true

module Hyrax
  class SoftwareForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:software)

    self.model_class = ::Software
  end
end