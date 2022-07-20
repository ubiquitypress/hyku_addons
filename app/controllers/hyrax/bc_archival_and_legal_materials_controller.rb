# frozen_string_literal: true

module Hyrax
  class BcArchivalAndLegalMaterialsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::BcArchivalAndLegalMaterial
    self.show_presenter = Hyrax::BcArchivalAndLegalMaterialPresenter
  end
end
