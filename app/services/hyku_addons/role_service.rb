# frozen_string_literal: true
module HykuAddons
  class RoleService < HykuAddons::QaSelectService
    def initialize(model: nil, locale: nil)
      super("role", model: model, locale: locale)
    end
  end
end
