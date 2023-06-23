# frozen_string_literal: true

module Hyrax
  class DataManagementPlanForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:data_management_plan)

    self.model_class = ::DataManagementPlan
  end
end