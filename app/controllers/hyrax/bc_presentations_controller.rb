# frozen_string_literal: true

module Hyrax
  class BcPresentationsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::BcPresentation
    self.show_presenter = Hyrax::BcPresentationPresenter
  end
end
