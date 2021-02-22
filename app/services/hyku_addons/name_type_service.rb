# frozen_string_literal: true
module HykuAddons
  class NameTypeService < HykuAddons::QaSelectService
    def initialize(model: nil, request: nil)
      super('name_type', model: model, request: request)
    end
  end
end
