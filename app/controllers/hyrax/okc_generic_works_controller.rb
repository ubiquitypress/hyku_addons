# frozen_string_literal: true

module Hyrax
  class OkcGenericWorksController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::OkcGenericWork
    self.show_presenter = Hyrax::OkcGenericWorkPresenter
  end
end
