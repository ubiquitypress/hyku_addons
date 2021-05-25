# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsOpenEducationalResource`
module Hyrax
  # Generated controller for RedlandsOpenEducationalResource
  class RedlandsOpenEducationalResourcesController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::RedlandsOpenEducationalResource
    self.show_presenter = Hyrax::RedlandsOpenEducationalResourcePresenter
  end
end
