# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsChaptersAndBookSection`
module Hyrax
  # Generated form for RedlandsChaptersAndBookSection
  class RedlandsChaptersAndBookSectionForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:redlands_chapters_and_book_section)

    self.model_class = ::RedlandsChaptersAndBookSection
  end
end
