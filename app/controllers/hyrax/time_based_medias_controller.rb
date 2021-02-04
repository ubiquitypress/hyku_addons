# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work TimeBasedMedia`
module Hyrax
  # Generated controller for TimeBasedMedia
  class TimeBasedMediasController < ::ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::TimeBasedMedia

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::TimeBasedMediaPresenter
  end
end
