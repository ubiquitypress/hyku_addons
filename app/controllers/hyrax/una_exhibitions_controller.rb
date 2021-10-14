# frozen_string_literal: true

module Hyrax
  class UnaExhibitionsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::UnaExhibition

    self.show_presenter = Hyrax::UnaExhibitionPresenter
  end
end
