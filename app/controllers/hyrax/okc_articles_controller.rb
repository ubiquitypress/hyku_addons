# frozen_string_literal: true

module Hyrax
  class OkcArticlesController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::OkcArticle
    self.show_presenter = Hyrax::OkcArticlePresenter
  end
end
