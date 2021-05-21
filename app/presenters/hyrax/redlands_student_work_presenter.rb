# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsStudentWork`
module Hyrax
  class RedlandsStudentWorkPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::WorkPresenterBehavior

    def self.delegated_methods
      %i[title alt_title resource_type creator alt_email abstract keyword subject
        qualification_name org_unit language license publisher date_published contributor location
        longitude latitude advisor add_info].freeze
    end
    include ::HykuAddons::PresenterDelegatable
  end
end
