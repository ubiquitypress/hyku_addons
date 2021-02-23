# frozen_string_literal: true

module Hyrax
  class PacificThesisOrDissertationsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::PacificThesisOrDissertation
    self.show_presenter = Hyrax::PacificThesisOrDissertationPresenter
  end
end
