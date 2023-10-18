# frozen_string_literal: true

module Hyrax
  class UnaTimeBasedMediaForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:una_time_based_media)

    self.model_class = ::UnaTimeBasedMedia
  end
end
