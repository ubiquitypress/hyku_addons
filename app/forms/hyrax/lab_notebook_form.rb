# frozen_string_literal: true

module Hyrax
  class LabNotebookForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:lab_notebook)

    self.model_class = ::LabNotebook
  end
end