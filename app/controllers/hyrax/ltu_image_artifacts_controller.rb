# frozen_string_literal: true

module Hyrax
  class LtuImageArtifactsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::LtuImageArtifact
    self.show_presenter = Hyrax::LtuImageArtifactPresenter
  end
end
