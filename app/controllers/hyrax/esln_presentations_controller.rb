# frozen_string_literal: true

module Hyrax
  class EslnPresentationsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::EslnPresentation
    self.show_presenter = Hyrax::EslnPresentationPresenter
  end
end
