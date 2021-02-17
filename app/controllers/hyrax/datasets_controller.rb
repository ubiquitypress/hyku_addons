# frozen_string_literal: true

module Hyrax
  class DatasetsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::Dataset
    self.show_presenter = Hyrax::DatasetPresenter
  end
end
