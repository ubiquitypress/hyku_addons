# frozen_string_literal: true

module Hyrax
  class LtuBookChaptersController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::LtuBookChapter
    self.show_presenter = Hyrax::LtuBookChapterPresenter
  end
end
