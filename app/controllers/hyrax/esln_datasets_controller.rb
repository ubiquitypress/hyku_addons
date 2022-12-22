# frozen_string_literal: true

module Hyrax
  class EslnDatasetsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::EslnDataset
    self.show_presenter = Hyrax::EslnDatasetPresenter
  end
end
