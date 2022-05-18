# frozen_string_literal: true

module Hyrax
  class UngArticlesController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::UngArticle
    self.show_presenter = Hyrax::UngArticlePresenter
  end
end
