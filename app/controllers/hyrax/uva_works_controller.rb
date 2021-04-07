# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work UvaWork`
module Hyrax
  # Generated controller for UvaWork
  class UvaWorksController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::UvaWork

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::UvaWorkPresenter
  end
end
