# frozen_string_literal: true

module Hyrax
  class DataManagementPlansController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::DataManagementPlan
    self.show_presenter = Hyrax::DataManagementPlanPresenter
  end
end