# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverMultimedia`
module Hyrax
  # Generated form for DenverMultimedia
  class DenverMultimediaForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:denver_multimedia)

    self.model_class = ::DenverMultimedia
  end
end
