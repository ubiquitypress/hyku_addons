# frozen_string_literal: true

module Hyrax
  class LacImagesController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::LacImage
    self.show_presenter = Hyrax::LacImagePresenter
  end
end
