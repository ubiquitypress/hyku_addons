# frozen_string_literal: true

module Hyrax
  class GrantRecordsController < ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include ::HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::GrantRecord
    self.show_presenter = Hyrax::GrantRecordPresenter
  end
end