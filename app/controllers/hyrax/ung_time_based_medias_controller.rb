# frozen_string_literal: true

module Hyrax
  class UngTimeBasedMediasController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::UngTimeBasedMedia
    self.show_presenter = Hyrax::UngTimeBasedMediaPresenter
  end
end
