# frozen_string_literal: true

module Hyrax
  class LtuArticlesController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::LtuSerial
    self.show_presenter = Hyrax::LtuSerialPresenter
  end
end
