# frozen_string_literal: true

module Hyrax
  class PacificTextWorksController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::PacificTextWork
    self.show_presenter = Hyrax::PacificTextWorkPresenter
  end
end
