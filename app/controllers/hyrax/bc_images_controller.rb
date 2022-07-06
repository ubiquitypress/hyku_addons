# frozen_string_literal: true

module Hyrax
  class BcImagesController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::BcImage
    self.show_presenter = Hyrax::BcImagePresenter
  end
end
