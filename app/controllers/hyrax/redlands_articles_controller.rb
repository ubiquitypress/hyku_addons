# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work RedlandsArticle`
module Hyrax
  # Generated controller for RedlandsArticle
  class RedlandsArticlesController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::RedlandsArticle
    self.show_presenter = Hyrax::RedlandsArticlePresenter
  end
end
