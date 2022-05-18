# frozen_string_literal: true

module Hyrax
  class UngBookForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:ung_book)

    self.model_class = ::UngBook
  end
end
