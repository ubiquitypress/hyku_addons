# frozen_string_literal: true

module Hyrax
  class UnaArticlesController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::UnaArticle
    self.show_presenter = Hyrax::UnaArticlePresenter
  end
end
