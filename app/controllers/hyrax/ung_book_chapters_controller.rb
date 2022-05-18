# frozen_string_literal: true

module Hyrax
  class UngBookChaptersController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::UngBookChapter
    self.show_presenter = Hyrax::UngBookChapterPresenter
  end
end
