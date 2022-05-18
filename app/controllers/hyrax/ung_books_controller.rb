# frozen_string_literal: true

module Hyrax
  class UngBooksController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::UngBook
    self.show_presenter = Hyrax::UngBookPresenter
  end
end
