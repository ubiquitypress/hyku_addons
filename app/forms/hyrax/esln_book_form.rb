# frozen_string_literal: true

module Hyrax
  class EslnBookForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:esln_book)

    self.model_class = ::EslnBook
  end
end
