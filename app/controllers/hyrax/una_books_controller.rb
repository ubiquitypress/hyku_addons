# frozen_string_literal: true

module Hyrax
  class UnaBooksController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::UnaBook
    self.show_presenter = Hyrax::UnaBookPresenter
  end
end
