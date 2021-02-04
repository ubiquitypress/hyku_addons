# frozen_string_literal: true
module HykuAddons
  class ContributorGroupService < HykuAddons::QaSelectService
    def initialize(model: nil)
      super('contributor_group', model: model)
    end
  end
end
