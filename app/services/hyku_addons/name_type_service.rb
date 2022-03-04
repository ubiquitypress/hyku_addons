# frozen_string_literal: true
module HykuAddons
  class NameTypeService < HykuAddons::QaSelectService
    def initialize(model: nil, locale: nil)
      super("name_type", model: model, locale: locale)
    end
  end
end
