# frozen_string_literal: true

module Hyrax
  class BcArchivalMaterialsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::BcArchivalMaterial
    self.show_presenter = Hyrax::BcArchivalMaterialPresenter
  end
end
