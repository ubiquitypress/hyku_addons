# frozen_string_literal: true
module HykuAddons
  class InstitutionService < HykuAddons::QaSelectService
    def initialize(model: nil, locale: nil)
      super("institution", model: model, locale: locale)
    end
  end
end
