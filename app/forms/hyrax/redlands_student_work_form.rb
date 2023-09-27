# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsStudentWork`
module Hyrax
  # Generated form for RedlandsStudentWork
  class RedlandsStudentWorkForm < Hyrax::Forms::WorkForm
    include Hyrax::DOI::DataCiteDOIFormBehavior

    include ::HykuAddons::Schema::WorkForm
    include Hyrax::FormFields(:redlands_student_work)

    self.model_class = ::RedlandsStudentWork
  end
end
