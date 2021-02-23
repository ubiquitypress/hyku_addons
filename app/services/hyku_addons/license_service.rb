# frozen_string_literal: true

module HykuAddons
  class LicenseService < HykuAddons::QaSelectService
    def initialize(model: nil)
      super('licenses', model: model)
    end
  end
end
