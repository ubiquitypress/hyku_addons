# frozen_string_literal: true

module Hyrax
  class OpenEducationalResourcesController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::OpenEducationalResource
    self.show_presenter = Hyrax::OpenEducationalResourcePresenter
  end
end