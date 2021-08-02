# frozen_string_literal: true
# Generated via
#  `rails generate hyrax:work DenverBook`
module Hyrax
  # Generated controller for DenverBook
  class DenverBooksController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::DenverBook
    self.show_presenter = Hyrax::DenverBookPresenter
  end
end
