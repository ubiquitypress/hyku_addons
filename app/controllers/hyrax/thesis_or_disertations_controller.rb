# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work ThesisOrDisertation`
module Hyrax
  # Generated controller for ThesisOrDisertation
  class ThesisOrDisertationsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::ThesisOrDisertation

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::ThesisOrDisertationPresenter
  end
end
