# frozen_string_literal: true
module HykuAddons
  class RefereedService < HykuAddons::QaSelectService
    def initialize(model: nil, locale: nil)
      super("refereed", model: model, locale: locale)
    end
  end
end
