# frozen_string_literal: true
module HykuAddons
  class StylePeriodService < HykuAddons::QaSelectService
    def initialize(model: nil, locale: nil)
      super("style_period", model: model, locale: locale)
    end
  end
end
