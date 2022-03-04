# frozen_string_literal: true

module HykuAddons
  class InstitutionalRelationshipService < HykuAddons::QaSelectService
    def initialize(model: nil, locale: nil)
      super("institutional_relationship", model: model, locale: locale)
    end
  end
end
