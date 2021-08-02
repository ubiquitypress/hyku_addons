# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverPresentationMaterial`
module Hyrax
  # Generated controller for DenverPresentationMaterial
  class DenverPresentationMaterialsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::DenverPresentationMaterial
    self.show_presenter = Hyrax::DenverPresentationMaterialPresenter
  end
end
