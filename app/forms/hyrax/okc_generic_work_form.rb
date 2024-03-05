# frozen_string_literal: true

module Hyrax
  # Generated form for OkcGenericWork
  class OkcGenericWorkForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:okc_generic_work)

    self.model_class = ::OkcGenericWork
  end
end
