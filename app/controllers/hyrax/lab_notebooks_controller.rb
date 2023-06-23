# frozen_string_literal: true

module Hyrax
  class LabNotebooksController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::LabNotebook
    self.show_presenter = Hyrax::LabNotebookPresenter
  end
end