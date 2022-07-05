# frozen_string_literal: true

module Hyrax
  class BcBooksController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::BcBook
    self.show_presenter = Hyrax::BcBookPresenter
  end
end
