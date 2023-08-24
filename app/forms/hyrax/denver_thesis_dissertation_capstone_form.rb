# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverThesisDissertationCapstone`
module Hyrax
  # Generated form for DenverThesisDissertationCapstone
  class DenverThesisDissertationCapstoneForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:denver_thesis_dissertation_capstone)

    self.model_class = ::DenverThesisDissertationCapstone
  end
end
