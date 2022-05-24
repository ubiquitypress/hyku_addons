# frozen_string_literal: true

module Hyrax
  class UngDatasetsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::UngDataset
    self.show_presenter = Hyrax::UngDatasetPresenter
  end
end
