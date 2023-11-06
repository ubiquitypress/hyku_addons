# frozen_string_literal: true

module Hyrax
  class BookForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:book)

    self.model_class = ::Book
  end
end
