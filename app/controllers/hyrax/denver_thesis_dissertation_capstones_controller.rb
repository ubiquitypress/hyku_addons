# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverThesisDissertationCapstone`
module Hyrax
  # Generated controller for DenverThesisDissertationCapstone
  class DenverThesisDissertationCapstonesController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::DenverThesisDissertationCapstone
    self.show_presenter = Hyrax::DenverThesisDissertationCapstonePresenter
  end
end
