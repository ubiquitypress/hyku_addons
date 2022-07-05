# frozen_string_literal: true

module Hyrax
  class BcBookForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:bc_book)

    self.model_class = ::BcBook
  end
end
