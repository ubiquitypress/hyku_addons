# frozen_string_literal: true
module Hyrax
  class UnaTimeBasedMediasController < ::ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::UnaTimeBasedMedia
    self.show_presenter = Hyrax::TimeBasedMediaPresenter
  end
end
