# frozen_string_literal: true

module Hyrax
  class LtuArticlesController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::LtuArticle
    self.show_presenter = Hyrax::LtuArticlePresenter
  end
end
