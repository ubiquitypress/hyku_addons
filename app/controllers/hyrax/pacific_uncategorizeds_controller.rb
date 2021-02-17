# frozen_string_literal: true

module Hyrax
  class PacificUncategorizedsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::PacificUncategorized
    self.show_presenter = Hyrax::PacificUncategorizedPresenter
  end
end
