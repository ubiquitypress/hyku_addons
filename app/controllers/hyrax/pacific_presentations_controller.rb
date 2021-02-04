# Generated via
#  `rails generate hyrax:work PacificPresentation`
module Hyrax
  # Generated controller for PacificPresentation
  class PacificPresentationsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::PacificPresentation

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::PacificPresentationPresenter
  end
end
