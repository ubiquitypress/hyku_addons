# frozen_string_literal: true

module Hyrax
  class UngImagesController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::UngImage
    self.show_presenter = Hyrax::UngImagePresenter
  end
end
