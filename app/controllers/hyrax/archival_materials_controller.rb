# frozen_string_literal: true

module Hyrax
  class ArchivalMaterialsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::ArchivalMaterial
    self.show_presenter = Hyrax::ArchivalMaterialPresenter
  end
end
