# Generated via
#  `rails generate hyrax:work PacificBookChapter`
module Hyrax
  # Generated controller for PacificBookChapter
  class PacificBookChaptersController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::PacificBookChapter

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::PacificBookChapterPresenter
  end
end
