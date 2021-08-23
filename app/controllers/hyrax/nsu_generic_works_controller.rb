# frozen_string_literal: true

module Hyrax
  class NsuGenericWorksController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::NsuGenericWork
    self.show_presenter = Hyrax::NsuGenericWorkPresenter
  end
end
