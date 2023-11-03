# frozen_string_literal: true

module Hyrax
  class ReportForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:report)

    self.model_class = ::Report
  end
end
