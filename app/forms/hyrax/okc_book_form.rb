# frozen_string_literal: true

module Hyrax
  class OkcBookForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:okc_book)

    self.model_class = ::OkcBook
  end
end
