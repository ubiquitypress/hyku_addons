# frozen_string_literal: true

module Hyrax
  class DenverDatasetsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::DenverDataset
    self.show_presenter = Hyrax::DenverDatasetPresenter
  end
end
