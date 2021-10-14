# frozen_string_literal: true

module Hyrax
  class NsuArticlesController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::NsuArticle
    self.show_presenter = Hyrax::NsuArticlePresenter
  end
end
