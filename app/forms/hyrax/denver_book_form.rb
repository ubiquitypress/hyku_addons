# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverBook`
module Hyrax
  # Generated form for DenverBook
  class DenverBookForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:denver_book)

    self.model_class = ::DenverBook
  end
end
