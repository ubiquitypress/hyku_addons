# frozen_string_literal: true
module HykuAddons
  class LanguageService < HykuAddons::QaSelectService
    def initialize(model: nil)
      super('language', model: model)
    end
  end
end
