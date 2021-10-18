# frozen_string_literal: true

module Hyrax
  class UnaImagesController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::UnaImage

    self.show_presenter = Hyrax::UnaImagePresenter
  end
end
