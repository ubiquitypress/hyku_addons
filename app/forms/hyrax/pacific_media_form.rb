# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificMedia`
module Hyrax
  class PacificMediaForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:pacific_media)

    self.model_class = ::PacificMedia
  end
end
