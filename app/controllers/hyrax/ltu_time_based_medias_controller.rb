# frozen_string_literal: true

module Hyrax
  class LtuTimeBasedMediasController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::LtuTimeBasedMedia
    self.show_presenter = Hyrax::LtuTimeBasedMediaPresenter
  end
end
