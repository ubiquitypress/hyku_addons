# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work ExhibitionItem`
module Hyrax
  # Generated controller for ExhibitionItem
  class ExhibitionItemsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::ExhibitionItem

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::ExhibitionItemPresenter
  end
end
