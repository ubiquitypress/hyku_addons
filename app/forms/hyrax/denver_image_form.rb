# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverImage`
module Hyrax
  # Generated form for DenverImage
  class DenverImageForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:denver_image)

    self.model_class = ::DenverImage
  end
end
