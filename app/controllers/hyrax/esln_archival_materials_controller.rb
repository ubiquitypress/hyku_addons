# frozen_string_literal: true

module Hyrax
  class EslnArchivalMaterialsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::EslnArchivalMaterial
    self.show_presenter = Hyrax::EslnArchivalMaterialPresenter
  end
end
