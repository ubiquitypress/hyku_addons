# frozen_string_literal: true

module Hyrax
  class ExhibitionItemsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::ExhibitionItem

    self.show_presenter = Hyrax::ExhibitionItemPresenter
  end
end
