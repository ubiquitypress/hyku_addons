# frozen_string_literal: true

module Hyrax
  class BooksController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::Book
    self.show_presenter = Hyrax::BookPresenter
  end
end
