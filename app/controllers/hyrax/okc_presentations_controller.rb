# frozen_string_literal: true

module Hyrax
  class OkcPresentationsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::OkcPresentation
    self.show_presenter = Hyrax::OkcPresentationPresenter
  end
end
