# frozen_string_literal: true

module Hyrax
  # Generated form for NsuGenericWork
  class NsuGenericWorkForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:nsu_generic_work)

    self.model_class = ::NsuGenericWork
  end
end
