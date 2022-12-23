# frozen_string_literal: true

module Hyrax
  class EslnTemplateWorkForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:esln_template_work)

    self.model_class = ::EslnTemplateWork
  end
end
