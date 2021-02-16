# frozen_string_literal: true

module Hyrax
  class PacificNewsClippingsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::PacificNewsClipping
    self.show_presenter = Hyrax::PacificNewsClippingPresenter
  end
end
