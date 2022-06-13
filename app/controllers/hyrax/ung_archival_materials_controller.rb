# frozen_string_literal: true

module Hyrax
  class UngArchivalMaterialsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::UngArchivalMaterial
    self.show_presenter = Hyrax::UngArchivalMaterialPresenter
  end
end
