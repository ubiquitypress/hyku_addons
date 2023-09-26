# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsMedia`
module Hyrax
  # Generated form for RedlandsMedia
  class RedlandsMediaForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:redlands_media)

    self.model_class = ::RedlandsMedia
  end
end
