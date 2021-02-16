# frozen_string_literal: true

module Hyrax
  class PacificPresentationsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::PacificPresentation
    self.show_presenter = Hyrax::PacificPresentationPresenter
  end
end
