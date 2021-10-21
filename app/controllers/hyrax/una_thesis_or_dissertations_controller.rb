# frozen_string_literal: true

module Hyrax
  class UnaThesisOrDissertationsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::UnaThesisOrDissertation
    self.show_presenter = Hyrax::UnaThesisOrDissertationPresenter
  end
end
