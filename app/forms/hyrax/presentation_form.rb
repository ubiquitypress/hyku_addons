# frozen_string_literal: true

module Hyrax
  class PresentationForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:presentation)

    self.model_class = ::Presentation
  end
end
