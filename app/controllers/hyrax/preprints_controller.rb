# frozen_string_literal: true

module Hyrax
  class PreprintsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::Preprint
    self.show_presenter = Hyrax::PreprintPresenter
  end
end
