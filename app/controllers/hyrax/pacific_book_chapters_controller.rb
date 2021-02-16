# frozen_string_literal: true

module Hyrax
  class PacificBookChaptersController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::PacificBookChapter
    self.show_presenter = Hyrax::PacificBookChapterPresenter
  end
end
