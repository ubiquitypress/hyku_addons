# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverDataset`
module Hyrax
  class DenverDatasetPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::WorkPresenterBehavior

    def self.delegated_methods
      %i[title alt_title resource_type creator institution abstract keyword
         subject_text org_unit date_published version_number alternate_identifier
         related_identifier license contributor medium extent language location
         longitude latitude time add_info].freeze
    end
    include ::HykuAddons::PresenterDelegatable
  end
end
