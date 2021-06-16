# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work AnschutzWork`
module Hyrax
  # Generated controller for AnschutzWork
  class AnschutzWorksController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::Article
    self.show_presenter = Hyrax::ArticlePresenter
  end
end
