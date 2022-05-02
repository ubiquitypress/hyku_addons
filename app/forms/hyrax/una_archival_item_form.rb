# frozen_string_literal: true
module Hyrax
  class UnaArchivalItemForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:una_archival_item)

    self.model_class = ::UnaArchivalItem
  end
end
