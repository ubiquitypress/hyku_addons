# frozen_string_literal: true

module Hyrax
  class LacArchivalMaterialsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::LacArchivalMaterial
    self.show_presenter = Hyrax::LacArchivalMaterialPresenter
  end
end
