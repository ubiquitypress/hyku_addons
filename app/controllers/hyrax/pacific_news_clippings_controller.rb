# Generated via
#  `rails generate hyrax:work PacificNewsClipping`
module Hyrax
  # Generated controller for PacificNewsClipping
  class PacificNewsClippingsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::PacificNewsClipping

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::PacificNewsClippingPresenter
  end
end
