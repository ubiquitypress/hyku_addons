# frozen_string_literal: true

module HykuAddons
  class InstitutionalRelationshipService < HykuAddons::QaSelectService
    def initialize(model: nil)
      super('institutional_relationship', model: model)
    end
  end
end
