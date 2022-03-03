# frozen_string_literal: true

module HykuAddons
  class ContributorInstitutionalRelationshipService < HykuAddons::QaSelectService
    def initialize(model: nil, locale: nil)
      super("contributor_institutional_relationship", model: model, locale: locale)
    end
  end
end
