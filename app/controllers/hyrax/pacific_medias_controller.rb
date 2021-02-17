# frozen_string_literal: true

module Hyrax
  class PacificMediasController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::PacificMedia
    self.show_presenter = Hyrax::PacificMediaPresenter
  end
end
