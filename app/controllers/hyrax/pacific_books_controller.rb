# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificBook`
module Hyrax
  # Generated controller for PacificBook
  class PacificBooksController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::PacificBook

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::PacificBookPresenter
  end
end
