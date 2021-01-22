# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work PacificImage`
module Hyrax
  # Generated controller for PacificImage
  class PacificImagesController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::PacificImage

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::PacificImagePresenter
  end
end
