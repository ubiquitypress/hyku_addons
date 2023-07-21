# frozen_string_literal: true

module Hyrax
  class LacTimeBasedMediaForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:lac_time_based_media)

    self.model_class = ::LacTimeBasedMedia
  end
end
