# frozen_string_literal: true

module Hyrax
  class LtuPresentationsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::LtuPresentation
    self.show_presenter = Hyrax::LtuPresentationPresenter
  end
end
