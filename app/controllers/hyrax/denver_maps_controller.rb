# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverMap`
module Hyrax
  # Generated controller for DenverMap
  class DenverMapsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::DenverMap
    self.show_presenter = Hyrax::DenverMapPresenter
  end
end
