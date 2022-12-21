# frozen_string_literal: true

module Hyrax
  class LacBookForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:lac_book)

    self.model_class = ::LacBook
  end
end
