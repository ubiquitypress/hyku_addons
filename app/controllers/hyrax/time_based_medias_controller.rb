# frozen_string_literal: true

module Hyrax
  class TimeBasedMediasController < ::ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::TimeBasedMedia
    self.show_presenter = Hyrax::TimeBasedMediaPresenter
  end
end
