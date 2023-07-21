# frozen_string_literal: true

module Hyrax
  class LtuTimeBasedMediaForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:ltu_time_based_media)

    self.model_class = ::LtuTimeBasedMedia
  end
end
