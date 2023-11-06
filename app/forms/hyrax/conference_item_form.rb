# frozen_string_literal: true

module Hyrax
  class ConferenceItemForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:conference_item)

    self.model_class = ::ConferenceItem
  end
end
