# frozen_string_literal: true

module Hyrax
  class LtuSerialForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior
    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:ltu_serial)
    self.model_class = ::LtuSerial
  end
end
