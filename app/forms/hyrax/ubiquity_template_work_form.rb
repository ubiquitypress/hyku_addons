# frozen_string_literal: true

module Hyrax
  class UbiquityTemplateWorkForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:ubiquity_template_work)

    self.model_class = ::UbiquityTemplateWork
  end
end
