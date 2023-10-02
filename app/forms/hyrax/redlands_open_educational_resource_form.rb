# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsOpenEducationalResource`
module Hyrax
  # Generated form for RedlandsOpenEducationalResource
  class RedlandsOpenEducationalResourceForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:redlands_open_educational_resource)

    self.model_class = ::RedlandsOpenEducationalResource
  end
end
