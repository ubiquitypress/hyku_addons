# frozen_string_literal: true

module Hyrax
  class UbiquityTemplateWorkForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::Schema::WorkForm
    include Hyax::FormFields(:ubiquity_template_work)

    self.model_class = ::UbiquityTemplateWork
  end
end
