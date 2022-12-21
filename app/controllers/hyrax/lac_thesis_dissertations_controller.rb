# frozen_string_literal: true

module Hyrax
  class LacThesisDissertationsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::LacThesisDissertation
    self.show_presenter = Hyrax::LacThesisDissertationPresenter
  end
end
