# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsChaptersAndBookSection`
module Hyrax
  # Generated controller for RedlandsChaptersAndBookSection
  class RedlandsChaptersAndBookSectionsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::RedlandsChaptersAndBookSection
    self.show_presenter = Hyrax::RedlandsChaptersAndBookSectionPresenter
  end
end
