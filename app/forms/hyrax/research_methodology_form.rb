# frozen_string_literal: true

module Hyrax
  class ResearchMethodologyForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:research_methodology)

    self.model_class = ::ResearchMethodology
  end
end