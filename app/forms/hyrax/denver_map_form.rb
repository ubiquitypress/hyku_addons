# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverMap`
module Hyrax
  # Generated form for DenverMap
  class DenverMapForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:denver_map)

    self.model_class = ::DenverMap
  end
end
