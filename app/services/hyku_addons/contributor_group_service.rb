# frozen_string_literal: true
module HykuAddons
  class ContributorGroupService < HykuAddons::QaSelectService
    def initialize(model: nil, request: nil)
      super('contributor_group', model: model, request: request)
    end
  end
end
