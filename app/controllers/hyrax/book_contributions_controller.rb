# frozen_string_literal: true

module Hyrax
  class BookContributionsController < ::ApplicationController
    include Hyrax::WorksControllerBehavior
    include Hyrax::BreadcrumbsForWorks
    include HykuAddons::WorksControllerBehavior

    self.curation_concern_type = ::BookContribution
    self.show_presenter = Hyrax::BookContributionPresenter
  end
end
