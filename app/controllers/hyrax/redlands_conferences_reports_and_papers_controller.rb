# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsConferencesReportsAndPaper`
module Hyrax
  # Generated controller for RedlandsConferencesReportsAndPaper
  class RedlandsConferencesReportsAndPapersController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior
    
    self.curation_concern_type = ::RedlandsConferencesReportsAndPaper
    self.show_presenter = Hyrax::RedlandsConferencesReportsAndPaperPresenter
  end
end
