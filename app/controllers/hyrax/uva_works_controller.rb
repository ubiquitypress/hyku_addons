# frozen_string_literal: true

module Hyrax
  class UvaWorksController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::UvaWork
    self.show_presenter = Hyrax::UvaWorkPresenter
  end
end
