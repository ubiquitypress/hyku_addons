# frozen_string_literal: true

module Hyrax
  class ExhibitionItemForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:exhibition_item)

    self.model_class = ::ExhibitionItem
  end
end
