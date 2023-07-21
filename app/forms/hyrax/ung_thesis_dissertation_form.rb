# frozen_string_literal: true

module Hyrax
  class UngThesisDissertationForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:ung_thesis_dissertation)

    self.model_class = ::UngThesisDissertation
  end
end
