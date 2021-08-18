# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverThesisDissertationCapstone`
module Hyrax
  class DenverThesisDissertationCapstonePresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::WorkPresenterBehavior

    def self.delegated_methods
      %i[title resource_type creator abstract keyword subject degree qualification_level
         qualification_name advisor committee_member org_unit add_info
         date_published pagination alternate_identifier library_of_congress_classification
         related_identifier publisher place_of_publication license rights_holder rights_statement
         contributor table_of_contents references medium extent language].freeze
    end
    include ::HykuAddons::PresenterDelegatable
  end
end
