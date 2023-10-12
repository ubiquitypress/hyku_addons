# frozen_string_literal: true

module Hyrax
  class PacificBookForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:pacific_book)

    self.model_class = ::PacificBook
  end
end
