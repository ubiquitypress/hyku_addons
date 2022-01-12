# frozen_string_literal: true

module Hyrax
  class UbiquityTemplateWorksController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::UbiquityTemplateWork
    self.show_presenter = Hyrax::UbiquityTemplateWorkPresenter
  end
end
