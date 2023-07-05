# frozen_string_literal: true

module Hyrax
  class GrantRecordForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:grant_record)

    self.model_class = ::GrantRecord
  end
end