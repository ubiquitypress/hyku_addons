# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsBook`
module Hyrax
  # Generated controller for RedlandsBook
  class RedlandsBooksController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::RedlandsBook
    self.show_presenter = Hyrax::RedlandsBookPresenter
  end
end
