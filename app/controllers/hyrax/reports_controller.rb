# frozen_string_literal: true

module Hyrax
  class ReportsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::Report
    self.show_presenter = Hyrax::ReportPresenter
  end
end
