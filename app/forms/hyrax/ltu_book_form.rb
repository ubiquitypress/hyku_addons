# frozen_string_literal: true

module Hyrax
  class LtuBookForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:ltu_book)

    self.model_class = ::LtuBook
  end
end
