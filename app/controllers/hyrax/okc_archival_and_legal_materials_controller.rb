# frozen_string_literal: true

module Hyrax
  class OkcArchivalAndLegalMaterialsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::OkcArchivalAndLegalMaterial
    self.show_presenter = Hyrax::OkcArchivalAndLegalMaterialPresenter
  end
end
