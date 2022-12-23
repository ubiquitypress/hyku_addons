# frozen_string_literal: true

module Hyrax
  class EslnTemplateWorksController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::EslnTemplateWork
    self.show_presenter = Hyrax::EslnTemplateWorkPresenter
  end
end
