# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work PacificThesisOrDissertation`
module Hyrax
  # Generated controller for PacificThesisOrDissertation
  class PacificThesisOrDissertationsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::PacificThesisOrDissertation

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::PacificThesisOrDissertationPresenter
  end
end
