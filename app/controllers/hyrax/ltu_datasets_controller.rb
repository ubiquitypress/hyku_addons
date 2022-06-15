# frozen_string_literal: true

module Hyrax
  class LtuDatasetsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::LtuDataset
    self.show_presenter = Hyrax::LtuDatasetPresenter
  end
end
