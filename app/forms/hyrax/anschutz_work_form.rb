# frozen_string_literal: true

module Hyrax
  class AnschutzWorkForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:anschutz_work)

    self.model_class = ::AnschutzWork
  end
end
