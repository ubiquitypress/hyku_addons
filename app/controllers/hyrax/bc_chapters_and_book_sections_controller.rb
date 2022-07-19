# frozen_string_literal: true

module Hyrax
  class BcChaptersAndBookSectionsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::BcChaptersAndBookSection
    self.show_presenter = Hyrax::BcChaptersAndBookSectionPresenter
  end
end
