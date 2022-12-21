# frozen_string_literal: true

module Hyrax
  class LacTimeBasedMediasController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::LacTimeBasedMedia
    self.show_presenter = Hyrax::LacTimeBasedMediaPresenter
  end
end
