# frozen_string_literal: true

module Hyrax
  class PreprintForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:preprint)

    self.model_class = ::Preprint
  end
end
