# frozen_string_literal: true

module HykuAddons
  class ContributorInstitutionalRelationshipService < HykuAddons::QaSelectService
    def initialize(model: nil)
      super('contributor_institutional_relationship', model: model)
    end
  end
end

