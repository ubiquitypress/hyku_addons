# frozen_string_literal: true

module Hyrax
  class EslnArticlesController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::EslnArticle
    self.show_presenter = Hyrax::EslnArticlePresenter
  end
end
