# frozen_string_literal: true
module Hyrax
  class UnaChaptersAndBookSectionsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::UnaChaptersAndBookSection
    self.show_presenter = Hyrax::UnaChaptersAndBookSectionPresenter
  end
end
