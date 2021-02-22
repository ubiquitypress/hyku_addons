# frozen_string_literal: true
module HykuAddons
  class ResourceTypesService < HykuAddons::QaSelectService
    def initialize(model: nil, request: nil)
      super('resource_types', model: model, request: request)
    end
  end
end
