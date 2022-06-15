# frozen_string_literal: true

module Hyrax
  class LtuImagesController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::LtuImage
    self.show_presenter = Hyrax::LtuImagePresenter
  end
end
