# frozen_string_literal: true

module Hyrax
  class BcArticlesController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::BcArticle
    self.show_presenter = Hyrax::BcArticlePresenter
  end
end
