# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsMedia`
module Hyrax
  # Generated controller for RedlandsMedia
  class RedlandsMediasController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::RedlandsMedia
    self.show_presenter = Hyrax::RedlandsMediaPresenter
  end
end
