# frozen_string_literal: true

module Hyrax
  class SoftwaresController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::Software
    self.show_presenter = Hyrax::SoftwarePresenter
  end
end