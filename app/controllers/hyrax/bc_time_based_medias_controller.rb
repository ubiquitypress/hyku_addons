# frozen_string_literal: true

module Hyrax
  class BcTimeBasedMediasController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::BcTimeBasedMedia
    self.show_presenter = Hyrax::BcTimeBasedMediaPresenter
  end
end
