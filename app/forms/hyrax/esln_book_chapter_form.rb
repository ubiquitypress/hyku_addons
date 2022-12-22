# frozen_string_literal: true

module Hyrax
  class EslnBookChapterForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:esln_book_chapter)

    self.model_class = ::EslnBookChapter
  end
end
