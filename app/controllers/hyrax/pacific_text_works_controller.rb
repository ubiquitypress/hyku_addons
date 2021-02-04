# Generated via
#  `rails generate hyrax:work PacificTextWork`
module Hyrax
  # Generated controller for PacificTextWork
  class PacificTextWorksController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::PacificTextWork

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::PacificTextWorkPresenter
  end
end
