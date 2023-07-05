# frozen_string_literal: true

module Hyrax
  class MinuteForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:minute)

    self.model_class = ::Minute
  end
end
