# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverBookChapter`
module Hyrax
  # Generated form for DenverBookChapter
  class DenverBookChapterForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:denver_book_chapter)

    self.model_class = ::DenverBookChapter
  end
end
