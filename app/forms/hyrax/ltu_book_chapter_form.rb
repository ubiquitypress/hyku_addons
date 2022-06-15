# frozen_string_literal: true

module Hyrax
  class LtuBookChapterForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:ltu_book_chapter)

    self.model_class = ::LtuBookChapter
  end
end
