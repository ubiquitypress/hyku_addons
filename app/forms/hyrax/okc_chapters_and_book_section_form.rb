# frozen_string_literal: true

module Hyrax
  class OkcChaptersAndBookSectionForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:okc_chapters_and_book_section)

    self.model_class = ::OkcChaptersAndBookSection
  end
end
