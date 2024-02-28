# frozen_string_literal: true

module Hyrax
  class OkcBooksController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::OkcBook
    self.show_presenter = Hyrax::OkcBookPresenter
  end
end
