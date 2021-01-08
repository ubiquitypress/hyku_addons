# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work BookContribution`
module Hyrax
  # Generated controller for BookContribution
  class BookContributionsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::BookContribution

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::BookContributionPresenter
  end
end
