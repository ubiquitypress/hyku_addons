# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverImage`
module Hyrax
  # Generated controller for DenverImage
  class DenverImagesController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::DenverImage
    self.show_presenter = Hyrax::DenverImagePresenter
  end
end
