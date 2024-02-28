# frozen_string_literal: true

module Hyrax
  class OkcTimeBasedMediasController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::OkcTimeBasedMedia
    self.show_presenter = Hyrax::OkcTimeBasedMediaPresenter
  end
end
