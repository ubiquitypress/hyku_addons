# frozen_string_literal: true
module HykuAddons
  class ResourceTypesService < HykuAddons::QaSelectService
    def initialize(model: nil)
      super('resource_types', model: model)
    end
  end
end
