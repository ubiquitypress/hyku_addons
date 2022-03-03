# frozen_string_literal: true
module HykuAddons
  class FunderService < HykuAddons::QaSelectService
    def initialize(model: nil, locale: nil)
      super("funder", model: model, locale: locale)
    end
  end
end
