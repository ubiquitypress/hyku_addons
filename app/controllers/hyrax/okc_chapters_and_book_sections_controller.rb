# frozen_string_literal: true

module Hyrax
  class OkcChaptersAndBookSectionsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::OkcChaptersAndBookSection
    self.show_presenter = Hyrax::OkcChaptersAndBookSectionPresenter
  end
end
