# frozen_string_literal: true

module Hyrax
  class ArticlesController < ::ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::Article
    self.show_presenter = Hyrax::ArticlePresenter
  end
end
