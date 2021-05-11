# frozen_string_literal: true
module HykuAddons
  class OrgUnitService < HykuAddons::QaSelectService
    def initialize(model: nil)
      super('org_unit', model: model)
    end
  end
end
