# frozen_string_literal: true

module Hyrax
  class ResearchMethodologiesController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::ResearchMethodology
    self.show_presenter = Hyrax::ResearchMethodologyPresenter
  end
end