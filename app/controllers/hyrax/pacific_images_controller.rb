# frozen_string_literal: true

module Hyrax
  class PacificImagesController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::PacificImage
    self.show_presenter = Hyrax::PacificImagePresenter
  end
end
