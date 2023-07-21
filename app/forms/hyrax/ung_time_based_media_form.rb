# frozen_string_literal: true

module Hyrax
  class UngTimeBasedMediaForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:ung_time_based_media)

    self.model_class = ::UngTimeBasedMedia
  end
end
