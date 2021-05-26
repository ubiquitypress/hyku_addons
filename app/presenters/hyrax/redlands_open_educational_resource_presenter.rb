# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsOpenEducationalResource`
module Hyrax
  class RedlandsOpenEducationalResourcePresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::WorkPresenterBehavior

    def self.delegated_methods
      %i[title alt_title resource_type creator alt_email abstract keyword subject
         org_unit language license table_of_contents publisher place_of_publication date_published
         edition pagination official_link adapted_from audience contributor related_material location longitude latitude
         prerequisites suggested_student_reviewers suggested_reviewers add_info].freeze
    end
    include ::HykuAddons::PresenterDelegatable
  end
end
