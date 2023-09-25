# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsBook`
module Hyrax
  # Generated form for RedlandsBook
  class RedlandsBookForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:redlands_book)

    self.model_class = ::RedlandsBook
  end
end
