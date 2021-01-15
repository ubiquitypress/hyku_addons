# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work ConferenceItem`
module Hyrax
  # Generated controller for ConferenceItem
  class ConferenceItemsController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerAdditionalMimeTypesBehavior

    self.curation_concern_type = ::ConferenceItem

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::ConferenceItemPresenter
  end
end
