# frozen_string_literal: true
module Hyrax
  class UnaChaptersAndBookSectionForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:una_chapters_and_book_section)

    self.model_class = ::UnaChaptersAndBookSection
  end
end
