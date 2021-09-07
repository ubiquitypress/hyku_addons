# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverMultimedia`
module Hyrax
  # Generated controller for DenverMultimedia
  class DenverMultimediasController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::DenverMultimedia
    self.show_presenter = Hyrax::DenverMultimediaPresenter
  end
end
