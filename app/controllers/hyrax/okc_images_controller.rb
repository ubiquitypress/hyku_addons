# frozen_string_literal: true

module Hyrax
  class OkcImagesController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::OkcImage
    self.show_presenter = Hyrax::OkcImagePresenter
  end
end
