# frozen_string_literal: true
module HykuAddons
  class RelationTypeService < HykuAddons::QaSelectService
    def initialize(model: nil, request: nil)
      super('relation_type', model: model, request: request)
    end
  end
end
