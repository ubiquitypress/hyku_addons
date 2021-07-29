# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverSerialPublication`
module Hyrax
  # Generated controller for DenverSerialPublication
  class DenverSerialPublicationsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::DenverSerialPublication
    self.show_presenter = Hyrax::DenverSerialPublicationPresenter
  end
end
