# frozen_string_literal: true
module HykuAddons
  class GeoreferencedService < HykuAddons::QaSelectService
    def initialize(model: nil, locale: nil)
      super("georeferenced", model: model, locale: locale)
    end
  end
end
