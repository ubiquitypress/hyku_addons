# frozen_string_literal: true

module Hyrax
  class UngBookChapterForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:ung_book_chapter)

    self.model_class = ::UngBookChapter
  end
end
