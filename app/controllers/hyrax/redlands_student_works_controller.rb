# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsStudentWork`
module Hyrax
  # Generated controller for RedlandsStudentWork
  class RedlandsStudentWorksController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::RedlandsStudentWork
    self.show_presenter = Hyrax::RedlandsStudentWorkPresenter
  end
end
