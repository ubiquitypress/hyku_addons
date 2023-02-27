# frozen_string_literal: true
module HykuAddons
  class AltClassService < HykuAddons::QaSelectService
    def initialize(model: nil, locale: nil)
      super("alt_class", model: model, locale: locale)
    end
  end
end
