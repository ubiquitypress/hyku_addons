# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverArticle`
module Hyrax
  # Generated controller for DenverArticle
  class DenverArticlesController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::DenverArticle
    self.show_presenter = Hyrax::DenverArticlePresenter
  end
end
