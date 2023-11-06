# frozen_string_literal: true

module Hyrax
  class TimeBasedMediaForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:time_based_media)

    self.model_class = ::TimeBasedMedia
  end
end
