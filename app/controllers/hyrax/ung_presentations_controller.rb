# frozen_string_literal: true

module Hyrax
  class UngPresentationsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::UngPresentation
    self.show_presenter = Hyrax::UngPresentationPresenter
  end
end
