# frozen_string_literal: true

module Hyrax
  class ThesisOrDissertationsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::ThesisOrDissertation
    self.show_presenter = Hyrax::ThesisOrDissertationPresenter
  end
end
