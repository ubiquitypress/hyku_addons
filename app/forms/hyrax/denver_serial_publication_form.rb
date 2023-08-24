# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverSerialPublication`
module Hyrax
  # Generated form for DenverSerialPublication
  class DenverSerialPublicationForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:denver_serial_publication)

    self.model_class = ::DenverSerialPublication
  end
end
