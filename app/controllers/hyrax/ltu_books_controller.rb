# frozen_string_literal: true

module Hyrax
  class LtuBooksController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::LtuBook
    self.show_presenter = Hyrax::LtuBookPresenter
  end
end
