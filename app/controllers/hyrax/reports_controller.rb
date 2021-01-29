# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work Report`
module Hyrax
  # Generated controller for Report
  class ReportsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::Report

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::ReportPresenter
  end
end
