# frozen_string_literal: true
module HykuAddons
  class AudienceService < HykuAddons::QaSelectService
    def initialize(model: nil, locale: nil)
      super("audience", model: model, locale: locale)
    end
  end
end
