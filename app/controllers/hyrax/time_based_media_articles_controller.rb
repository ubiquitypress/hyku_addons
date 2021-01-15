# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work TimeBasedMediaArticle`
module Hyrax
  # Generated controller for TimeBasedMediaArticle
  class TimeBasedMediaArticlesController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerAdditionalMimeTypesBehavior

    self.curation_concern_type = ::TimeBasedMediaArticle

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::TimeBasedMediaArticlePresenter
  end
end
