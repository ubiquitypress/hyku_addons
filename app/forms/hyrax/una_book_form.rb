# frozen_string_literal: true
module Hyrax
  class UnaBookForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:una_book)

    self.model_class = ::UnaBook
  end
end
