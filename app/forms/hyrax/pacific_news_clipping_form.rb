# frozen_string_literal: true
module Hyrax
  class PacificNewsClippingForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:pacific_news_clipping)

    self.model_class = ::PacificNewsClipping
  end
end
