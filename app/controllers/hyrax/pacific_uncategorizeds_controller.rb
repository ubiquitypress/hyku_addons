# Generated via
#  `rails generate hyrax:work PacificUncategorized`
module Hyrax
  # Generated controller for PacificUncategorized
  class PacificUncategorizedsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::PacificUncategorized

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::PacificUncategorizedPresenter
  end
end
