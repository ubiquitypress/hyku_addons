# frozen_string_literal: true

module Hyrax
  class BcTimeBasedMediaForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:bc_time_based_media)

    self.model_class = ::BcTimeBasedMedia
  end
end
