# frozen_string_literal: true

module Hyrax
  class PacificArticlesController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::PacificArticle
    self.show_presenter = Hyrax::PacificArticlePresenter
  end
end
