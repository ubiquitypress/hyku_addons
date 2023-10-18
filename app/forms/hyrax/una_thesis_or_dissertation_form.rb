# frozen_string_literal: true
module Hyrax
  class UnaThesisOrDissertationForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:una_thesis_or_dissertation)

    self.model_class = ::UnaThesisOrDissertation
  end
end
