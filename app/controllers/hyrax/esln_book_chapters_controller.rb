# frozen_string_literal: true

module Hyrax
  class EslnBookChaptersController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::EslnBookChapter
    self.show_presenter = Hyrax::EslnBookChapterPresenter
  end
end
