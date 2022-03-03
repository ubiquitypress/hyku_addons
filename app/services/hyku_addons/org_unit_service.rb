# frozen_string_literal: true
module HykuAddons
  class OrgUnitService < HykuAddons::QaSelectService
    def initialize(model: nil, locale: nil)
      super("org_unit", model: model, locale: locale)
    end
  end
end
