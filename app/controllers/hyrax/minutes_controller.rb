# frozen_string_literal: true

module Hyrax
  class MinutesController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::Minute
    self.show_presenter = Hyrax::MinutePresenter
  end
end
