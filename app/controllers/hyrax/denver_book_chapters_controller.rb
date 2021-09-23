# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverBookChapter`
module Hyrax
  # Generated controller for DenverBookChapter
  class DenverBookChaptersController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::DenverBookChapter
    self.show_presenter = Hyrax::DenverBookChapterPresenter
  end
end
