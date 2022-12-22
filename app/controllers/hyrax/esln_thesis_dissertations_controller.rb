# frozen_string_literal: true

module Hyrax
  class EslnThesisDissertationsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::EslnThesisDissertation
    self.show_presenter = Hyrax::EslnThesisDissertationPresenter
  end
end
