# frozen_string_literal: true
module Hyrax
  class UnaPresentationsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::UnaPresentation
    self.show_presenter = Hyrax::UnaPresentationPresenter
  end
end
