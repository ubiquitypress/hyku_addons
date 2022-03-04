# frozen_string_literal: true

module HykuAddons
  class LicenseService < HykuAddons::QaSelectService
    def initialize(model: nil, locale: nil)
      super("licenses", model: model, locale: locale)
    end
  end
end
