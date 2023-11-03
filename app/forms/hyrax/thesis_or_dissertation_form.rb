# frozen_string_literal: true

module Hyrax
  class ThesisOrDissertationForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:thesis_or_dissertation)

    self.model_class = ::ThesisOrDissertation
  end
end
