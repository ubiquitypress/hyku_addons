# frozen_string_literal: true
module HykuAddons
  class RoleService < HykuAddons::QaSelectService
    def initialize(model: nil)
      super('role', model: model)
    end
  end
end
