# frozen_string_literal: true

module Hyrax
  class AnschutzWorksController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::AnschutzWork
    self.show_presenter = Hyrax::AnschutzWorkPresenter
  end
end
