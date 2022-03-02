# frozen_string_literal: true
module HykuAddons
  class LanguageService < HykuAddons::QaSelectService
    def initialize(model: nil, locale: nil)
      super("language", model: model, locale: locale)
    end
  end
end
