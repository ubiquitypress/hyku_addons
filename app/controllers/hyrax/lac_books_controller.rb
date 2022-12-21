# frozen_string_literal: true

module Hyrax
  class LacBooksController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::LacBook
    self.show_presenter = Hyrax::LacBookPresenter
  end
end
