# frozen_string_literal: true

module Hyrax
  class OkcTimeBasedMediaForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:okc_time_based_media)

    self.model_class = ::OkcTimeBasedMedia
  end
end
