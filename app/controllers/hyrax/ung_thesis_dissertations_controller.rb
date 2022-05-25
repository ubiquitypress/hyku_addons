# frozen_string_literal: true

module Hyrax
  class UngThesisDissertationsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::UngThesisDissertation
    self.show_presenter = Hyrax::UngThesisDissertationPresenter
  end
end
