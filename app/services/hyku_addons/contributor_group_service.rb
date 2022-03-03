# frozen_string_literal: true
module HykuAddons
  class ContributorGroupService < HykuAddons::QaSelectService
    def initialize(model: nil, locale: nil)
      super("contributor_group", model: model, locale: locale)
    end
  end
end
