# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work PacificMedia`
module Hyrax
  # Generated controller for PacificMedia
  class PacificMediasController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::PacificMedia

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::PacificMediaPresenter
  end
end
