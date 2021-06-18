# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work AnschutzWork`
module Hyrax
  # Generated form for AnschutzWork
  class AnschutzWorkForm < Hyrax::Forms::WorkForm
    include ::HykuAddons::Schema::WorkForm

    include Hyrax::FormFields(:anschutz_work)

    self.model_class = ::AnschutzWork

    include Hyrax::DOI::DOIFormBehavior
    include Hyrax::DOI::DataCiteDOIFormBehavior
  end
end
