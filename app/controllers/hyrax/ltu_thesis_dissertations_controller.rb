# frozen_string_literal: true

module Hyrax
  class LtuThesisDissertationsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::LtuThesisDissertation
    self.show_presenter = Hyrax::LtuThesisDissertationPresenter
  end
end
