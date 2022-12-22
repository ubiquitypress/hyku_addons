# frozen_string_literal: true

module Hyrax
  class EslnBooksController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::EslnBook
    self.show_presenter = Hyrax::EslnBookPresenter
  end
end
