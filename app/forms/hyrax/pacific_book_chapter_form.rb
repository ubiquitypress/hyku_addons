# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificBookChapter`
module Hyrax
  # Generated form for PacificBookChapter
  class PacificBookChapterForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:pacific_book_chapter)

    self.model_class = ::PacificBookChapter
  end
end
