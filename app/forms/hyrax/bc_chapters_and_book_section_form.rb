# frozen_string_literal: true

module Hyrax
  class BcChaptersAndBookSectionForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:bc_chapters_and_book_section)

    self.model_class = ::BcChaptersAndBookSection
  end
end
