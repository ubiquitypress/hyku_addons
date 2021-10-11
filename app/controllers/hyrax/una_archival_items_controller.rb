# frozen_string_literal: true

module Hyrax
  class UnaArchivalItemsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::UnaArchivalItem
    self.show_presenter = Hyrax::UnaArchivalItemPresenter
  end
end
