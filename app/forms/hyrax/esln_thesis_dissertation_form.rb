# frozen_string_literal: true

module Hyrax
  class EslnThesisDissertationForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:esln_thesis_dissertation)

    self.model_class = ::EslnThesisDissertation
  end
end
