# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsStudentWork`
module Hyrax
  class RedlandsStudentWorkPresenter < Hyrax::WorkShowPresenter
    include ::HykuAddons::Schema::Presenter(:redlands_student_work)
    include ::HykuAddons::WorkPresenterBehavior
    include ::HykuAddons::PresenterDelegatable
  end
end
