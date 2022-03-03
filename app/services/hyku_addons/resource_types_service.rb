# frozen_string_literal: true
module HykuAddons
  class ResourceTypesService < HykuAddons::QaSelectService
    def initialize(model: nil, locale: nil)
      super("resource_types", model: model, locale: locale)
    end
  end
end
