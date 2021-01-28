# frozen_string_literal: true

# Generated via
#  `rails generate hyrax:work PacificArticle`
module Hyrax
  # Generated controller for PacificArticle
  class PacificArticlesController < ApplicationController
    # Adds Hyrax behaviors to the controller.
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    self.curation_concern_type = ::PacificArticle

    # Use this line if you want to use a custom presenter
    self.show_presenter = Hyrax::PacificArticlePresenter
  end
end
