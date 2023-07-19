# frozen_string_literal: true

module Hyrax
  class PresentationsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::Presentation
    self.show_presenter = Hyrax::PresentationPresenter
  end
end
